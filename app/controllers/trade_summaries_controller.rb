require "ostruct"

class TradeSummariesController < ApplicationController
  include Pagy::Backend
  include TimezoneHandling
  before_action :set_selected_date, only: [:daily, :weekly, :monthly]

  def daily
    @trade_logs = current_user.trade_logs
      .where(trade_date: @selected_date)
      .includes(:broker_account)

    @statistics = AnalyzeTradeLogs.new(@trade_logs).call
    @month_report = MonthReport.generate_for_month(current_user, @selected_date.beginning_of_month)
  end

  def weekly
    week_start = @selected_date.beginning_of_week
    week_end = @selected_date.end_of_week

    @trade_logs = current_user.trade_logs
      .where(trade_date: week_start..week_end)
      .includes(:broker_account)

    @statistics = AnalyzeTradeLogs.new(@trade_logs).call
    @month_report = MonthReport.generate_for_month(current_user, @selected_date.beginning_of_month)
  end

  def monthly
    month_start = @selected_date.beginning_of_month
    month_end = @selected_date.end_of_month

    @trade_logs = current_user.trade_logs
      .where(trade_date: month_start..month_end)
      .includes(:broker_account)

    active_trades = @trade_logs.select { |trade| trade.gross_pnl.present? }
    @buy_trades = active_trades.select { |trade| trade.buy_quantity.positive? }
    @sell_trades = active_trades.select { |trade| trade.sell_quantity.positive? }

    @statistics = AnalyzeTradeLogs.new(@trade_logs).call
    @buy_statistics = AnalyzeTradeLogs.new(@buy_trades).call
    @sell_statistics = AnalyzeTradeLogs.new(@sell_trades).call
    @month_report = MonthReport.generate_for_month(current_user, @selected_date.beginning_of_month)
  end

  private

  def set_selected_date
    @selected_date = params[:date]&.to_date || Date.today
  end
end
