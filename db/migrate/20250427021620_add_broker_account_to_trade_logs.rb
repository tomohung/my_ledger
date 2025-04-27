class AddBrokerAccountToTradeLogs < ActiveRecord::Migration[8.0]
  def change
    add_reference :trade_logs, :broker_account, null: false, foreign_key: true
  end
end
