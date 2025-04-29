class TradeSummariesController < ApplicationController
  include Pagy::Backend
  before_action :set_date_range, only: [:daily, :weekly, :monthly]

  def daily
    @pagy, @summaries = pagy(
      current_user.trade_logs
        .where(trade_date: @start_date..@end_date)
        .group(:trade_date)
        .select("trade_date, COUNT(*) as total_trades, SUM(profit_loss) as total_profit_loss")
        .order(trade_date: :desc)
    )
  end

  def weekly
    @pagy, @summaries = pagy(
      current_user.trade_logs
        .where(trade_date: @start_date..@end_date)
        .group("DATE_TRUNC('week', trade_date)")
        .select("DATE_TRUNC('week', trade_date) as week_start, COUNT(*) as total_trades, SUM(profit_loss) as total_profit_loss")
        .order("week_start DESC")
    )
  end

  def monthly
    @pagy, @summaries = pagy(
      current_user.trade_logs
        .where(trade_date: @start_date..@end_date)
        .group("DATE_TRUNC('month', trade_date)")
        .select("DATE_TRUNC('month', trade_date) as month_start, COUNT(*) as total_trades, SUM(profit_loss) as total_profit_loss")
        .order("month_start DESC")
    )
  end

  private

  def set_date_range
    @start_date = params[:start_date]&.to_date || 1.year.ago.to_date
    @end_date = params[:end_date]&.to_date || Date.today
  end
end
