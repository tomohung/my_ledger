class CreateMonthReports < ActiveRecord::Migration[8.0]
  def change
    create_table :month_reports do |t|
      t.references :user, null: false, foreign_key: true
      t.date :report_date, null: false
      t.decimal :initial_capital, precision: 10, scale: 2, null: false
      t.decimal :ending_capital, precision: 10, scale: 2, null: false
      t.decimal :total_gross_pnl, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :total_commission, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :total_tax, precision: 10, scale: 2, null: false, default: 0.0
      t.decimal :total_net_pnl, precision: 10, scale: 2, null: false, default: 0.0
      t.integer :total_trades, null: false, default: 0
      t.integer :winning_trades, null: false, default: 0
      t.integer :losing_trades, null: false, default: 0

      t.timestamps
    end

    add_index :month_reports, [:user_id, :report_date], unique: true
  end
end
