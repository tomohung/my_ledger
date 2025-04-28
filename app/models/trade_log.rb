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

  # --- 資料清理輔助方法 ---
  def self.clean_value(value)
    return nil if value.nil? || value.strip.empty?
    # 移除 ="..." 格式
    cleaned = value.strip.gsub(/^="|"$/, "")
    (cleaned == "") ? nil : cleaned
  end

  def self.parse_decimal(value)
    cleaned = clean_value(value)
    cleaned ? BigDecimal(cleaned) : nil
  end

  def self.parse_integer(value)
    cleaned = clean_value(value)
    cleaned&.to_i
  end

  def self.parse_date(value)
    cleaned = clean_value(value)
    cleaned ? Date.parse(cleaned) : nil
  end
  # --- END ---

  def self.import_from_csv_string(csv_string)
    trade_data_pairs = []
    temp_row = nil

    begin
      CSV.parse(csv_string, headers: true) do |row|
        # Skip header and summary rows
        next if row[1] == "交易日期" # Skip header
        next if row[2] == "台幣小計" # Skip summary

        # Clean the row values
        cleaned_row = row.map { |value| clean_value(value) }

        # If this is an entry trade (has buy quantity)
        if cleaned_row[7].present? # buy_quantity present
          temp_row = cleaned_row
        # If this is an exit trade (has sell quantity) and we have a matching entry
        elsif cleaned_row[8].present? && temp_row # sell_quantity present
          if temp_row[1] == cleaned_row[1] && # same date
              temp_row[2] == cleaned_row[2] && # same product
              temp_row[3] == cleaned_row[3]    # same contract month
            trade_data_pairs << {
              entry_row: temp_row,
              exit_row: cleaned_row
            }
          else
            puts "Warning: Trade pair mismatch. Entry order: #{temp_row[16]}, Exit order: #{cleaned_row[16]}"
          end
          temp_row = nil
        end
      end

      # Process each trade pair
      trade_data_pairs.each do |pair|
        entry_row = pair[:entry_row]
        exit_row = pair[:exit_row]

        # Create trade log record
        TradeLog.create!(
          trade_date: parse_date(entry_row[1]),
          product_name: entry_row[2],
          contract_month: entry_row[3],
          position: "long", # Assuming all trades are long positions
          quantity: parse_integer(entry_row[7]), # buy_quantity
          entry_price: parse_decimal(entry_row[9]), # trade_price
          exit_price: parse_decimal(exit_row[9]), # trade_price
          gross_pnl: parse_decimal(exit_row[11]), # profit_loss
          commission: parse_decimal(exit_row[12]), # commission
          tax: parse_decimal(exit_row[13]), # tax
          net_pnl: parse_decimal(exit_row[14]), # net_profit_loss
          currency: exit_row[15], # currency
          entry_order_id: entry_row[16], # order_id
          exit_order_id: exit_row[16], # order_id
          raw_csv_data: csv_string
        )
      end
    rescue => e
      puts "Error importing CSV: #{e.message}"
      raise e
    end
  end
end
