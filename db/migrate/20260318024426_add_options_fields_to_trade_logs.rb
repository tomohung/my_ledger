class AddOptionsFieldsToTradeLogs < ActiveRecord::Migration[8.1]
  def change
    add_column :trade_logs, :strike_price, :decimal, precision: 10, scale: 2
    add_column :trade_logs, :call_put, :string
    add_column :trade_logs, :trade_type, :string, default: "futures", null: false
    add_index :trade_logs, :trade_type
  end
end
