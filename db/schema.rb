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

ActiveRecord::Schema[8.0].define(version: 2025_04_27_021620) do
  create_table "broker_accounts", force: :cascade do |t|
    t.string "name"
    t.string "account_number"
    t.string "broker"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_broker_accounts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "trade_logs", force: :cascade do |t|
    t.date "trade_date"
    t.string "product_name"
    t.string "contract_month"
    t.string "position"
    t.integer "quantity"
    t.decimal "entry_price", precision: 10, scale: 2
    t.decimal "exit_price", precision: 10, scale: 2
    t.decimal "gross_pnl", precision: 10, scale: 2
    t.decimal "commission", precision: 10, scale: 2
    t.decimal "tax", precision: 10, scale: 2
    t.decimal "net_pnl", precision: 10, scale: 2
    t.string "currency"
    t.string "entry_order_id"
    t.string "exit_order_id"
    t.text "raw_csv_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "broker_account_id", null: false
    t.index ["broker_account_id"], name: "index_trade_logs_on_broker_account_id"
    t.index ["contract_month"], name: "index_trade_logs_on_contract_month"
    t.index ["product_name"], name: "index_trade_logs_on_product_name"
    t.index ["trade_date"], name: "index_trade_logs_on_trade_date"
    t.index ["user_id"], name: "index_trade_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "broker_accounts", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "trade_logs", "broker_accounts"
  add_foreign_key "trade_logs", "users"
end
