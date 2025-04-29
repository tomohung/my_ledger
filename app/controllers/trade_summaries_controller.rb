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
        "COUNT(*) as total_trades",
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

    @summary = current_user.trade_logs
      .where(trade_date: month_start..month_end)
      .select(
        "COUNT(*) as total_trades",
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

  private

  def set_selected_date
    @selected_date = params[:date]&.to_date || Date.today
  end
end
