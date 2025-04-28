class ModifyTradeLogs2 < ActiveRecord::Migration[8.0]
  def change
    rename_column :trade_logs, :entry_price, :price
    rename_column :trade_logs, :entry_order_id, :order_id
    remove_column :trade_logs, :raw_csv_data, :text
  end
end
