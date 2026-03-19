class AddTradeTimeToTradeLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :trade_logs, :trade_time, :string
  end
end
