# == Schema Information
#
# Table name: trade_logs
#
#  id                :integer          not null, primary key
#  trade_date        :date             not null
#  product_name      :string
#  contract_month    :string
#  price             :decimal(10, 2)
#  gross_pnl         :decimal(10, 2)
#  commission        :decimal(10, 2)
#  tax               :decimal(10, 2)
#  net_pnl           :decimal(10, 2)
#  currency          :string           not null
#  order_id          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer          not null
#  broker_account_id :integer          not null
#  buy_quantity      :integer
#  sell_quantity     :integer
#  strike_price      :decimal(10, 2)
#  call_put          :string
#  trade_type        :string           default("futures"), not null
#  trade_time        :string
#
# Indexes
#
#  index_trade_logs_on_broker_account_id  (broker_account_id)
#  index_trade_logs_on_contract_month     (contract_month)
#  index_trade_logs_on_product_name       (product_name)
#  index_trade_logs_on_trade_date         (trade_date)
#  index_trade_logs_on_trade_type         (trade_type)
#  index_trade_logs_on_user_id            (user_id)
#
# Foreign Keys
#
#  broker_account_id  (broker_account_id => broker_accounts.id)
#  user_id            (user_id => users.id)
#
FactoryBot.define do
  factory :trade_log do
    trade_date { Date.today }
    product_name { "小台指" }
    contract_month { Date.today.strftime("%Y%m") }
    price { 20000 }
    gross_pnl { 500 }
    commission { 20 }
    tax { 20 }
    net_pnl { 460 }
    currency { "TWD" }
    sequence(:order_id) { |n| "order#{n}" }
    buy_quantity { 1 }
    sell_quantity { 0 }
    trade_type { "futures" }
    association :user
    association :broker_account

    trait :options do
      product_name { "臺指選擇權" }
      strike_price { 20000 }
      call_put { "C" }
      trade_type { "options" }
    end

    trait :losing do
      gross_pnl { -500 }
      net_pnl { -540 }
    end
  end
end
