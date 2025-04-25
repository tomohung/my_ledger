class AddUserToTradeLogs < ActiveRecord::Migration[8.0]
  def change
    add_reference :trade_logs, :user, null: false, foreign_key: true
  end
end
