class AddNotNullConstraintsToTradeLogs < ActiveRecord::Migration[8.0]
  def change
    change_column_null :trade_logs, :trade_date, false
    change_column_null :trade_logs, :net_pnl, false
    change_column_null :trade_logs, :currency, false
  end
end
