# == Schema Information
#
# Table name: trade_logs
#
#  id                :integer          not null, primary key
#  trade_date        :date             not null
#  product_name      :string
#  contract_month    :string
#  price             :decimal(10, 2)
#  gross_pnl         :decimal(10, 2)
#  commission        :decimal(10, 2)
#  tax               :decimal(10, 2)
#  net_pnl           :decimal(10, 2)
#  currency          :string           not null
#  order_id          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer          not null
#  broker_account_id :integer          not null
#  buy_quantity      :integer
#  sell_quantity     :integer
#  strike_price      :decimal(10, 2)
#  call_put          :string
#  trade_type        :string           default("futures"), not null
#  trade_time        :string
#
# Indexes
#
#  index_trade_logs_on_broker_account_id  (broker_account_id)
#  index_trade_logs_on_contract_month     (contract_month)
#  index_trade_logs_on_product_name       (product_name)
#  index_trade_logs_on_trade_date         (trade_date)
#  index_trade_logs_on_trade_type         (trade_type)
#  index_trade_logs_on_user_id            (user_id)
#
# Foreign Keys
#
#  broker_account_id  (broker_account_id => broker_accounts.id)
#  user_id            (user_id => users.id)
#

class TradeLog < ApplicationRecord
  belongs_to :user
  belongs_to :broker_account

  scope :futures, -> { where(trade_type: "futures") }
  scope :options, -> { where(trade_type: "options") }
  scope :by_trade_type, ->(type) { type.present? ? where(trade_type: type) : all }

  def self.import_from_csv_string(broker_account, csv_string)
    # Clean up Excel-style formatting after successful parse
    cleaned_csv = csv_string.gsub(/="([^"]*)"/, '\1')
    csv = CSV.parse(cleaned_csv, headers: true)

    success_count = 0
    failure_count = 0

    csv.each do |row|
      # Skip header and summary rows
      next if row["商品名稱"] == "台幣小計"

      strike = row["履約價格"].presence
      cp = row["C/P"].presence
      type = (strike && cp) ? "options" : "futures"

      create!(
        trade_date: Date.parse(row["交易日期"]),
        product_name: row["商品名稱"],
        contract_month: row["年月"],
        strike_price: strike&.to_f,
        call_put: cp,
        trade_type: type,
        price: row["成交價格"].presence&.to_f,
        gross_pnl: row["損益"].presence&.to_f,
        commission: row["手續費"].presence&.to_f,
        tax: row["交易稅"].presence&.to_f,
        net_pnl: row["淨損益"].presence&.to_f,
        currency: row["幣別"],
        order_id: row["委託書號"],
        buy_quantity: row["買口數"].to_i,
        sell_quantity: row["賣口數"].to_i,
        user_id: broker_account.user_id,
        broker_account_id: broker_account.id
      )
      success_count += 1
    rescue => e
      failure_count += 1
      Rails.logger.error("Error importing trade log #{row["委託書號"]}: #{e.message}")
    end

    {success_count: success_count, failure_count: failure_count}
  end

  def self.detect_csv_format(csv_string)
    cleaned_csv = csv_string.gsub(/="([^"]*)"/, '\1')
    headers = CSV.parse_line(cleaned_csv)
    if headers&.include?("委託序號") && headers&.include?("成交時間")
      :trade_time
    else
      :import
    end
  end

  def self.update_times_from_csv_string(user, csv_string)
    cleaned_csv = csv_string.gsub(/="([^"]*)"/, '\1')
    csv = CSV.parse(cleaned_csv, headers: true)

    updated_count = 0
    not_found_count = 0
    failure_count = 0

    csv.each do |row|
      order_id = row["委託序號"].presence
      trade_time = row["成交時間"].presence
      next unless order_id && trade_time

      trade_logs = user.trade_logs.where(order_id: order_id)
      if trade_logs.any?
        count = trade_logs.update_all(trade_time: trade_time)
        updated_count += count
      else
        not_found_count += 1
      end
    rescue => e
      failure_count += 1
      Rails.logger.error("Error updating trade time for order #{order_id}: #{e.message}")
    end

    {updated_count: updated_count, not_found_count: not_found_count, failure_count: failure_count}
  end
end
