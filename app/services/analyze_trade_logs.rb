class AnalyzeTradeLogs
  def initialize(trade_logs, initial_capital: nil)
    @trade_logs = trade_logs
    @initial_capital = initial_capital
  end

  def call
    {
      avg_profit: calculate_avg_profit,
      avg_loss: calculate_avg_loss,
      win_rate: calculate_win_rate,
      profit_count: profit_trades.count,
      loss_count: loss_trades.count,
      trade_count: @active_trades.count,
      max_profit: profit_trades.map(&:net_pnl).max || 0,
      max_loss: loss_trades.map(&:net_pnl).min || 0,
      total_gross_profit: active_trades.pluck(:gross_pnl).compact_blank.sum,
      total_net_profit: active_trades.pluck(:net_pnl).compact_blank.sum,
      avg_profit_loss_ratio: calculate_avg_profit_loss_ratio,
      max_profit_loss_ratio: calculate_max_profit_loss_ratio,
      average_pnl: calculate_average_pnl,
      total_commission: calculate_total_commission,
      total_tax: calculate_total_tax,
      max_consecutive_losses: calculate_max_consecutive_losses,
      max_consecutive_loss_days: calculate_max_consecutive_loss_days,
      profit_factor: calculate_profit_factor,
      expectancy: calculate_expectancy,
      max_drawdown: calculate_max_drawdown,
      max_drawdown_percentage: calculate_max_drawdown_percentage,
      equity_curve: calculate_equity_curve,
      pnl_by_weekday: calculate_pnl_by_weekday,
      pnl_by_product: calculate_pnl_by_product
    }
  end

  private

  def active_trades
    @active_trades ||= @trade_logs.select { |trade| trade.net_pnl.present? }
  end

  def profit_trades
    @profit_trades ||= @trade_logs.select { |trade| trade.net_pnl&.positive? }
  end

  def loss_trades
    @loss_trades ||= @trade_logs.select { |trade| trade.net_pnl&.negative? }
  end

  def calculate_avg_profit
    return 0 if profit_trades.empty?

    profit_trades.sum(&:net_pnl) / profit_trades.count
  end

  def calculate_avg_loss
    return 0 if loss_trades.empty?

    loss_trades.sum(&:net_pnl) / loss_trades.count
  end

  def calculate_win_rate
    return 0 if active_trades.empty?

    (profit_trades.count.to_f / active_trades.count * 100).round(2)
  end

  def calculate_avg_profit_loss_ratio
    return 0 if loss_trades.empty? || profit_trades.empty?

    (calculate_avg_profit.abs / calculate_avg_loss.abs).round(2)
  end

  def calculate_max_profit_loss_ratio
    return 0 if loss_trades.empty? || profit_trades.empty?

    max_profit = profit_trades.map(&:net_pnl).max
    min_loss = loss_trades.map(&:net_pnl).min
    (max_profit.abs / min_loss.abs).round(2)
  end

  def calculate_average_pnl
    return 0 if active_trades.empty?

    active_trades.sum(&:net_pnl) / active_trades.count
  end

  def calculate_total_commission
    @trade_logs.sum(&:commission).to_f
  end

  def calculate_total_tax
    @trade_logs.sum(&:tax).to_f
  end

  def calculate_max_consecutive_losses
    return 0 if @active_trades.empty?

    max_consecutive = 0
    current_consecutive = 0

    @active_trades.sort_by(&:trade_date).each do |trade|
      if trade.net_pnl&.negative?
        current_consecutive += 1
        max_consecutive = [max_consecutive, current_consecutive].max
      else
        current_consecutive = 0
      end
    end

    max_consecutive
  end

  def calculate_max_consecutive_loss_days
    return 0 if @active_trades.empty?

    # Group trades by date and sum their gross_pnl
    daily_pnl = @active_trades.group_by(&:trade_date).transform_values do |trades|
      trades.sum(&:net_pnl)
    end

    max_consecutive = 0
    current_consecutive = 0

    daily_pnl.sort_by { |date, _| date }.each do |date, pnl|
      if pnl.negative?
        current_consecutive += 1
        max_consecutive = [max_consecutive, current_consecutive].max
      else
        current_consecutive = 0
      end
    end

    max_consecutive
  end

  def calculate_profit_factor
    total_profit = profit_trades.sum(&:net_pnl)
    total_loss = loss_trades.sum(&:net_pnl).abs
    return 0 if total_loss.zero?

    (total_profit / total_loss).round(2)
  end

  def calculate_expectancy
    return 0 if active_trades.empty?

    win_rate = profit_trades.count.to_f / active_trades.count
    loss_rate = 1.0 - win_rate
    avg_win = calculate_avg_profit
    avg_loss = calculate_avg_loss

    (win_rate * avg_win + loss_rate * avg_loss).round(0)
  end

  def daily_cumulative_pnl
    @daily_cumulative_pnl ||= begin
      sorted = active_trades.sort_by(&:trade_date)
      daily_pnl = sorted.group_by(&:trade_date).transform_values { |trades| trades.sum(&:net_pnl) }
      cumulative = 0
      daily_pnl.sort_by { |date, _| date }.map do |date, pnl|
        cumulative += pnl
        [date, cumulative]
      end
    end
  end

  def calculate_equity_curve
    return {} if active_trades.empty?

    base = @initial_capital || 0
    daily_cumulative_pnl.to_h { |date, cum| [date, base + cum] }
  end

  def calculate_max_drawdown
    return 0 if active_trades.empty?

    base = @initial_capital || 0
    peak = base
    max_dd = 0

    daily_cumulative_pnl.each do |_date, cumulative|
      equity = base + cumulative
      peak = equity if equity > peak
      drawdown = peak - equity
      max_dd = drawdown if drawdown > max_dd
    end

    max_dd
  end

  def calculate_max_drawdown_percentage
    return 0 if active_trades.empty? || @initial_capital.nil? || @initial_capital.zero?

    base = @initial_capital
    peak = base
    max_dd_pct = 0

    daily_cumulative_pnl.each do |_date, cumulative|
      equity = base + cumulative
      peak = equity if equity > peak
      dd_pct = ((peak - equity) / peak * 100).round(2) if peak > 0
      max_dd_pct = dd_pct if dd_pct && dd_pct > max_dd_pct
    end

    max_dd_pct
  end

  def calculate_pnl_by_weekday
    return {} if active_trades.empty?

    weekday_data = active_trades.group_by { |t| t.trade_date.wday }
    weekday_data.transform_values do |trades|
      wins = trades.count { |t| t.net_pnl&.positive? }
      total = trades.count { |t| t.net_pnl.present? }
      {
        net_pnl: trades.sum(&:net_pnl),
        trade_count: total,
        win_rate: total > 0 ? (wins.to_f / total * 100).round(1) : 0
      }
    end
  end

  def calculate_pnl_by_product
    return {} if active_trades.empty?

    product_data = active_trades.group_by(&:product_name)
    product_data.transform_values do |trades|
      wins = trades.count { |t| t.net_pnl&.positive? }
      total = trades.count { |t| t.net_pnl.present? }
      {
        net_pnl: trades.sum(&:net_pnl),
        trade_count: total,
        win_rate: total > 0 ? (wins.to_f / total * 100).round(1) : 0,
        avg_pnl: total > 0 ? (trades.sum(&:net_pnl) / total).round(0) : 0
      }
    end.sort_by { |_, v| -v[:net_pnl] }.to_h
  end
end
