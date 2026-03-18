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
