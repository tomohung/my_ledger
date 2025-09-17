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

  def update_initial_capital
    @month_report = current_user.month_reports.find(params[:month_report_id])

    if @month_report.update(initial_capital_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("initial-capital-value", partial: "trade_summaries/capital_risk_management", locals: {month_report: @month_report}) }
        format.html { redirect_back fallback_location: daily_trade_summaries_path, notice: "期初資金已更新" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("edit-initial-capital-form", partial: "shared/form_errors", locals: {object: @month_report}) }
        format.html { redirect_back fallback_location: daily_trade_summaries_path, alert: "更新失敗" }
      end
    end
  end

  private

  def set_selected_date
    @selected_date = params[:date]&.to_date || Date.today
  end

  def initial_capital_params
    params.permit(:initial_capital)
  end
end
