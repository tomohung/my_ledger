class TradeLogStatisticsService
  def initialize(trade_logs)
    @trade_logs = trade_logs
  end

  def calculate
    {
      avg_profit: calculate_avg_profit,
      avg_loss: calculate_avg_loss,
      win_rate: calculate_win_rate,
      profit_count: profit_trades.count,
      loss_count: loss_trades.count,
      trade_count: @active_trades.count,
      max_profit: profit_trades.map(&:gross_pnl).max || 0,
      max_loss: loss_trades.map(&:gross_pnl).min || 0,
      total_gross_profit: active_trades.sum(&:gross_pnl),
      total_net_profit: active_trades.sum(&:net_pnl),
      profit_loss_ratio: calculate_profit_loss_ratio,
      total_commission: calculate_total_commission,
      total_tax: calculate_total_tax,
      max_consecutive_losses: calculate_max_consecutive_losses
    }
  end

  private

  def active_trades
    @active_trades ||= @trade_logs.select { |trade| trade.gross_pnl.present? }
  end

  def profit_trades
    @profit_trades ||= @trade_logs.select { |trade| trade.gross_pnl&.positive? }
  end

  def loss_trades
    @loss_trades ||= @trade_logs.select { |trade| trade.gross_pnl&.negative? }
  end

  def calculate_avg_profit
    return 0 if profit_trades.empty?
    profit_trades.sum(&:gross_pnl) / profit_trades.count
  end

  def calculate_avg_loss
    return 0 if loss_trades.empty?
    loss_trades.sum(&:gross_pnl) / loss_trades.count
  end

  def calculate_win_rate
    return 0 if active_trades.empty?
    (profit_trades.count.to_f / active_trades.count * 100).round(2)
  end

  def calculate_profit_loss_ratio
    return 0 if loss_trades.empty? || profit_trades.empty?
    (calculate_avg_profit.abs / calculate_avg_loss.abs).round(2)
  end

  def calculate_total_commission
    @trade_logs.sum(&:commission).to_f
  end

  def calculate_total_tax
    @trade_logs.sum(&:tax).to_f
  end

  def calculate_max_consecutive_losses
    return 0 if @active_trades.empty?

    current_streak = 0
    max_streak = 0

    @active_trades.sort_by(&:created_at).each do |trade|
      if trade.gross_pnl&.negative?
        current_streak += 1
        max_streak = [max_streak, current_streak].max
      else
        current_streak = 0
      end
    end

    max_streak
  end
end
