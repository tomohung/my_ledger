class CreateTradeLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :trade_logs do |t|
      t.date :trade_date
      t.string :product_name
      t.string :contract_month
      t.string :position # 'long' or 'short'
      t.integer :quantity
      t.decimal :entry_price, precision: 10, scale: 2 # 根據需要調整精度
      t.decimal :exit_price, precision: 10, scale: 2
      t.decimal :gross_pnl, precision: 10, scale: 2 # 損益
      t.decimal :commission, precision: 10, scale: 2 # 手續費
      t.decimal :tax, precision: 10, scale: 2        # 交易稅
      t.decimal :net_pnl, precision: 10, scale: 2    # 淨損益
      t.string :currency
      t.string :entry_order_id # 進場委託書號
      t.string :exit_order_id  # 出場委託書號
      t.text :raw_csv_data # 可選：儲存原始 CSV 行，方便追溯

      t.timestamps
    end

    add_index :trade_logs, :trade_date
    add_index :trade_logs, :product_name
    add_index :trade_logs, :contract_month
  end
end
