# == Schema Information
#
# Table name: month_reports
#
#  id               :integer          not null, primary key
#  user_id          :integer          not null
#  report_date      :date             not null
#  initial_capital  :decimal(10, 2)   not null
#  ending_capital   :decimal(10, 2)   not null
#  total_gross_pnl  :decimal(10, 2)   default(0.0), not null
#  total_commission :decimal(10, 2)   default(0.0), not null
#  total_tax        :decimal(10, 2)   default(0.0), not null
#  total_net_pnl    :decimal(10, 2)   default(0.0), not null
#  total_trades     :integer          default(0), not null
#  winning_trades   :integer          default(0), not null
#  losing_trades    :integer          default(0), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_month_reports_on_user_id                  (user_id)
#  index_month_reports_on_user_id_and_report_date  (user_id,report_date) UNIQUE
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
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
