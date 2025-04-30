require "ostruct"

class TradeSummariesController < ApplicationController
  include Pagy::Backend
  before_action :set_selected_date, only: [:daily, :weekly, :monthly]

  def daily
    @trade_logs = current_user.trade_logs
      .where(trade_date: @selected_date)
      .includes(:broker_account)
      .order(created_at: :desc)
  end

  def weekly
    week_start = @selected_date.beginning_of_week
    week_end = @selected_date.end_of_week

    @summary = current_user.trade_logs
      .where(trade_date: week_start..week_end)
      .select(
        "COUNT(CASE WHEN net_pnl IS NOT NULL THEN 1 END) as total_trades",
        "SUM(gross_pnl) as total_gross_pnl",
        "SUM(commission) as total_commission",
        "SUM(tax) as total_tax",
        "SUM(net_pnl) as total_net_pnl",
        "AVG(net_pnl) as average_net_pnl",
        "COUNT(CASE WHEN net_pnl > 0 THEN 1 END) as winning_trades",
        "COUNT(CASE WHEN net_pnl < 0 THEN 1 END) as losing_trades"
      )
      .first
  end

  def monthly
    month_start = @selected_date.beginning_of_month
    month_end = @selected_date.end_of_month

    # Get trade statistics
    trade_stats = current_user.trade_logs
      .where(trade_date: month_start..month_end)
      .select(
        "COUNT(CASE WHEN net_pnl IS NOT NULL THEN 1 END) as total_trades",
        "SUM(gross_pnl) as total_gross_pnl",
        "SUM(commission) as total_commission",
        "SUM(tax) as total_tax",
        "SUM(net_pnl) as total_net_pnl",
        "AVG(net_pnl) as average_net_pnl",
        "COUNT(CASE WHEN net_pnl > 0 THEN 1 END) as winning_trades",
        "COUNT(CASE WHEN net_pnl < 0 THEN 1 END) as losing_trades"
      )
      .first

    # Get or create month report for initial capital
    month_report = MonthReport.generate_for_month(current_user, month_start)

    # Create a summary object with all the information
    @summary = OpenStruct.new(
      total_trades: trade_stats.total_trades,
      total_gross_pnl: trade_stats.total_gross_pnl,
      total_commission: trade_stats.total_commission,
      total_tax: trade_stats.total_tax,
      total_net_pnl: trade_stats.total_net_pnl,
      average_net_pnl: trade_stats.average_net_pnl,
      winning_trades: trade_stats.winning_trades,
      losing_trades: trade_stats.losing_trades,
      initial_capital: month_report.initial_capital,
      remaining_capital: month_report.ending_capital,
      risk_amount_per_trade: month_report.ending_capital * current_user.risk_amount_percentage_per_trade / 100,
      risk_amount_per_day: month_report.ending_capital * current_user.risk_amount_percentage_per_day / 100,
      risk_amount_per_week: month_report.ending_capital * current_user.risk_amount_percentage_per_week / 100,
      risk_amount_per_month: month_report.ending_capital * current_user.risk_amount_percentage_per_month / 100
    )
  end

  private

  def set_selected_date
    @selected_date = params[:date]&.to_date || Date.today
  end
end
