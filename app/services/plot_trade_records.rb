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
      buyColor = input.color(color.red, "Buy Signal Color")
      sellColor = input.color(color.green, "Sell Signal Color")
      closeColor = input.color(color.gray, "Close Signal Color")
    PINE
  end

  def plotshape_calls
    trades_to_plot = @merge_to_5min ? merge_trades(@trades) : @trades.map { |t| [t] } # standard:disable Performance/ZipWithoutBlock
    buy_style = "shape.triangleup"
    sell_style = "shape.triangledown"
    close_style = "shape.xcross"

    trades_to_plot.map.with_index do |trade_group, index|
      trade = trade_group.first
      date = trade.date.split("/")
      time = trade.time.split(":")
      total_quantity = trade_group.sum(&:quantity)
      show_type = (trade.direction == "買") ? "Buys" : "Sells"
      trade_type = (trade.type == "新倉") ? "open" : "close"
      direction = (trade.direction == "買") ? "buy" : "sell"
      style, color =
        if trade.type.include?("新倉")
          if trade.direction.include?("買")
            [buy_style, "buyColor"]
          else
            [sell_style, "sellColor"]
          end
        else
          [close_style, "closeColor"]
        end

      <<~PINE
        // Trade #{index + 1} (#{trade_group.size} trades)
        #{trade_type}_#{index}_time = timestamp(#{date[0]}, #{date[1]}, #{date[2]}, #{time[0]}, #{time[1]}, #{time[2]})
        #{trade_type}_barTime#{index} = time_close[1]
        #{trade_type}_next_barTime#{index} = time_close
        #{trade_type}#{index}_condition = #{trade_type}_barTime#{index} < #{trade_type}_#{index}_time and #{trade_type}_next_barTime#{index} >= #{trade_type}_#{index}_time and show#{show_type}
        plotshape(#{trade_type}#{index}_condition ? #{trade.price} : na, title="#{trade_type} #{index + 1}", style=#{style}, location=location.absolute, color=#{color}, textcolor=#{color}, size=size.small, text="#{direction} #{trade.price} x#{total_quantity}")
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
