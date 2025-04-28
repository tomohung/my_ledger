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
#
# Indexes
#
#  index_trade_logs_on_broker_account_id  (broker_account_id)
#  index_trade_logs_on_contract_month     (contract_month)
#  index_trade_logs_on_product_name       (product_name)
#  index_trade_logs_on_trade_date         (trade_date)
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

  def self.import_from_csv_string(broker_account, csv_string)
    # Parse CSV data
    csv = CSV.parse(csv_string, headers: true)

    # Process trades sequentially
    entry_trade = nil

    csv.each do |row|
      next if row["項次"].blank? || row["商品名稱"] == "台幣小計"

      create!(
        trade_date: Date.parse(row["交易日期"]),
        product_name: row["商品名稱"],
        contract_month: row["年月"],
        entry_price: row["成交價格"].to_f,
        gross_pnl: row["損益"].to_f,
        commission: entry_trade["手續費"].to_f + row["手續費"].to_f,
        tax: entry_trade["交易稅"].to_f + row["交易稅"].to_f,
        net_pnl: row["淨損益"].to_f,
        currency: entry_trade["幣別"],
        entry_order_id: entry_trade["委託書號"],
        exit_order_id: row["委託書號"],
        buy_quantity: entry_trade["買口數"].to_i,
        sell_quantity: row["賣口數"].to_i,
        raw_csv_data: csv_string,
        user_id: broker_account.user_id,
        broker_account_id: broker_account.id
      )
    end
  end
end
