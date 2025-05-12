class PlotTradeRecords
  def initialize(trades, merge_to_5min: false)
    @trades = trades
    @merge_to_5min = merge_to_5min
  end

  def call
    return "" if @trades.empty?

    [
      variable_declarations,
      plotshape_calls
    ].join("\n\n")
  end

  private

  def variable_declarations
    <<~PINE
      // @version=6
      indicator("Transaction Data from #{@trades.first.date}", overlay=true)

      // Settings
      showBuys = input.bool(true, "Show Buy Signals")
      showSells = input.bool(true, "Show Sell Signals")
      buyColor = input.color(color.blue, "Buy Signal Color")
      sellColor = input.color(color.orange, "Sell Signal Color")
    PINE
  end

  def plotshape_calls
    trades_to_plot = @merge_to_5min ? merge_trades(@trades) : @trades.map { |t| [t] } # standard:disable Performance/ZipWithoutBlock

    trades_to_plot.map.with_index do |trade_group, index|
      trade = trade_group.first
      date = trade.date.split("/")
      time = trade.time.split(":")
      total_quantity = trade_group.sum(&:quantity)
      show_type = (trade.direction == "買") ? "Buys" : "Sells"

      <<~PINE
        // Trade #{index + 1} (#{trade_group.size} trades)
        #{trade.type}_#{index}_time = timestamp(#{date[0]}, #{date[1]}, #{date[2]}, #{time[0]}, #{time[1]}, #{time[2]})
        #{trade.type}_barTime#{index} = time_close[1]
        #{trade.type}_next_barTime#{index} = time_close
        #{trade.type}#{index}_condition = #{trade.type}_barTime#{index} < #{trade.type}_#{index}_time and #{trade.type}_next_barTime#{index} >= #{trade.type}_#{index}_time and show#{show_type}
        plotshape(#{trade.type}#{index}_condition ? #{trade.price} : na, title="#{trade.type} #{index + 1}", style=shape.xcross, location=location.absolute, color=#{(trade.direction == "買") ? "buyColor" : "sellColor"}, size=size.small, text="#{trade.direction} #{trade.price} x#{total_quantity}")
      PINE
    end.join("\n\n")
  end

  def merge_trades(trades)
    return [] if trades.empty?

    result = []
    current_group = []
    current_interval = nil

    trades.each do |trade|
      time = Time.parse("#{trade.date} #{trade.time}")
      interval = (time.min / 5) * 5  # Get the start of the 5-minute interval

      if current_interval.nil? || interval == current_interval
        current_group << trade
      else
        result << current_group if current_group.any?
        current_group = [trade]
      end

      current_interval = interval
    end

    result << current_group if current_group.any?
    result
  end
end
