# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_19_091315) do
  create_table "broker_accounts", force: :cascade do |t|
    t.string "account_number"
    t.string "broker"
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_broker_accounts_on_user_id"
  end

  create_table "month_reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "ending_capital", precision: 10, scale: 2, null: false
    t.decimal "initial_capital", precision: 10, scale: 2, null: false
    t.integer "losing_trades", default: 0, null: false
    t.date "report_date", null: false
    t.decimal "total_commission", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_gross_pnl", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_net_pnl", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "total_tax", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "total_trades", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "winning_trades", default: 0, null: false
    t.index ["user_id", "report_date"], name: "index_month_reports_on_user_id_and_report_date", unique: true
    t.index ["user_id"], name: "index_month_reports_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "trade_logs", force: :cascade do |t|
    t.integer "broker_account_id", null: false
    t.integer "buy_quantity"
    t.string "call_put"
    t.decimal "commission", precision: 10, scale: 2
    t.string "contract_month"
    t.datetime "created_at", null: false
    t.string "currency", null: false
    t.decimal "gross_pnl", precision: 10, scale: 2
    t.decimal "net_pnl", precision: 10, scale: 2
    t.string "order_id"
    t.decimal "price", precision: 10, scale: 2
    t.string "product_name"
    t.integer "sell_quantity"
    t.decimal "strike_price", precision: 10, scale: 2
    t.decimal "tax", precision: 10, scale: 2
    t.date "trade_date", null: false
    t.string "trade_time"
    t.string "trade_type", default: "futures", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["broker_account_id"], name: "index_trade_logs_on_broker_account_id"
    t.index ["contract_month"], name: "index_trade_logs_on_contract_month"
    t.index ["product_name"], name: "index_trade_logs_on_product_name"
    t.index ["trade_date"], name: "index_trade_logs_on_trade_date"
    t.index ["trade_type"], name: "index_trade_logs_on_trade_type"
    t.index ["user_id"], name: "index_trade_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.decimal "initial_capital", precision: 10, scale: 2, default: "0.0", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.text "risk_settings", default: "{}", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "broker_accounts", "users"
  add_foreign_key "month_reports", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "trade_logs", "broker_accounts"
  add_foreign_key "trade_logs", "users"
end
