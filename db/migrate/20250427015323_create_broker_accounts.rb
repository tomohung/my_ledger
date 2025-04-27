class CreateBrokerAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :broker_accounts do |t|
      t.string :name
      t.string :account_number
      t.string :broker
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
