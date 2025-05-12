class TradePlotsController < ApplicationController
  def new
  end

  def create
    csv_content = params[:csv_content]
    merge_to_5min = params[:merge_to_5min] == "1"

    trades = ParseTradeReport.new(csv_content).call
    @plot_script = PlotTradeRecords.new(trades, merge_to_5min: merge_to_5min).call

    render :new
  end
end
