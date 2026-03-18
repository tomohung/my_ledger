FactoryBot.define do
  factory :month_report do
    association :user
    report_date { Date.today.beginning_of_month }
    initial_capital { 100_000 }
    ending_capital { 100_000 }
    total_gross_pnl { 0 }
    total_commission { 0 }
    total_tax { 0 }
    total_net_pnl { 0 }
    total_trades { 0 }
    winning_trades { 0 }
    losing_trades { 0 }
  end
end
