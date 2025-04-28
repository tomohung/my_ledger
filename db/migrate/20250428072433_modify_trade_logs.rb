class ModifyTradeLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :trade_logs, :buy_quantity, :integer
    add_column :trade_logs, :sell_quantity, :integer
    remove_column :trade_logs, :position, :integer
    remove_column :trade_logs, :quantity, :integer
    remove_column :trade_logs, :exit_price, :decimal
    remove_column :trade_logs, :exit_order_id, :string
    change_column_null :trade_logs, :net_pnl, true
  end
end
