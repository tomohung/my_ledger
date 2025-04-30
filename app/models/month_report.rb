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
class MonthReport < ApplicationRecord
  belongs_to :user

  validates :report_date, presence: true
  validates :initial_capital, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :ending_capital, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :total_gross_pnl, presence: true
  validates :total_commission, presence: true
  validates :total_tax, presence: true
  validates :total_net_pnl, presence: true
  validates :total_trades, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :winning_trades, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :losing_trades, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :report_date, uniqueness: {scope: :user_id}

  before_validation :set_initial_capital, on: :create
  before_validation :calculate_ending_capital, on: :create

  def self.generate_for_month(user, date)
    month_start = date.beginning_of_month
    month_end = date.end_of_month

    # Find or initialize the month report
    report = find_or_initialize_by(user: user, report_date: month_start)

    # Get all trades for the month
    trades = user.trade_logs.active.where(trade_date: month_start..month_end)

    # Calculate statistics
    report.total_trades = trades.count
    report.winning_trades = trades.where("net_pnl >= 0").count
    report.losing_trades = trades.where("net_pnl < 0").count
    report.total_gross_pnl = trades.sum(:gross_pnl) || 0
    report.total_commission = trades.sum(:commission) || 0
    report.total_tax = trades.sum(:tax) || 0
    report.total_net_pnl = trades.sum(:net_pnl) || 0

    report.save!
    report
  end

  def win_rate
    return 0 if total_trades.zero?
    (winning_trades.to_f / total_trades * 100).round(1)
  end

  private

  def set_initial_capital
    return if initial_capital.present?

    # Try to get the ending capital from the previous month's report
    previous_month = user.month_reports
      .where("report_date < ?", report_date)
      .order(report_date: :desc)
      .first

    self.initial_capital = if previous_month
      previous_month.ending_capital
    else
      # If no previous report exists, use the user's initial capital
      user.initial_capital
    end
  end

  def calculate_ending_capital
    self.ending_capital = initial_capital + total_net_pnl
  end
end
