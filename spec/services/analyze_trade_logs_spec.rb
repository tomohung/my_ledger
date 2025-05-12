require "rails_helper"

RSpec.describe AnalyzeTradeLogs do
  describe "#call" do
    let(:trade_logs) do
      [
        double("TradeLog", gross_pnl: 100.0, net_pnl: 90.0, commission: 5.0, tax: 5.0, trade_date: Date.today),
        double("TradeLog", gross_pnl: -50.0, net_pnl: -55.0, commission: 5.0, tax: 0.0, trade_date: Date.today),
        double("TradeLog", gross_pnl: 200.0, net_pnl: 190.0, commission: 5.0, tax: 5.0, trade_date: Date.today),
        double("TradeLog", gross_pnl: -30.0, net_pnl: -35.0, commission: 5.0, tax: 0.0, trade_date: Date.today),
        double("TradeLog", gross_pnl: nil, net_pnl: nil, commission: 0.0, tax: 0.0, trade_date: Date.today)
      ]
    end

    let(:service) { described_class.new(trade_logs) }
    let(:result) { service.call }

    it "calculates correct statistics" do
      expect(result[:avg_profit]).to eq(150.0) # (100 + 200) / 2
      expect(result[:avg_loss]).to eq(-40.0) # (-50 + -30) / 2
      expect(result[:win_rate]).to eq(50.0) # 2 winning trades out of 4 active trades
      expect(result[:profit_count]).to eq(2)
      expect(result[:loss_count]).to eq(2)
      expect(result[:trade_count]).to eq(4)
      expect(result[:max_profit]).to eq(200.0)
      expect(result[:max_loss]).to eq(-50.0)
      expect(result[:total_gross_profit]).to eq(220.0) # 100 + (-50) + 200 + (-30)
      expect(result[:total_net_profit]).to eq(190.0) # 90 + (-55) + 190 + (-35)
      expect(result[:avg_profit_loss_ratio]).to eq(3.75) # 150 / 40
      expect(result[:max_profit_loss_ratio]).to eq(4.0) # 200 / 50
      expect(result[:total_commission]).to eq(20.0) # 5 * 4
      expect(result[:total_tax]).to eq(10.0) # 5 * 2
    end

    context "with consecutive losses" do
      let(:trade_logs) do
        [
          double("TradeLog", gross_pnl: -100.0, net_pnl: -105.0, commission: 5.0, tax: 0.0, trade_date: Date.today),
          double("TradeLog", gross_pnl: -50.0, net_pnl: -55.0, commission: 5.0, tax: 0.0, trade_date: Date.today),
          double("TradeLog", gross_pnl: 200.0, net_pnl: 190.0, commission: 5.0, tax: 5.0, trade_date: Date.today),
          double("TradeLog", gross_pnl: -30.0, net_pnl: -35.0, commission: 5.0, tax: 0.0, trade_date: Date.today),
          double("TradeLog", gross_pnl: -20.0, net_pnl: -25.0, commission: 5.0, tax: 0.0, trade_date: Date.today)
        ]
      end

      it "calculates max consecutive losses" do
        expect(result[:max_consecutive_losses]).to eq(2)
      end
    end

    context "with empty trade logs" do
      let(:trade_logs) { [] }

      it "returns zero values" do
        expect(result[:avg_profit]).to eq(0.0)
        expect(result[:avg_loss]).to eq(0.0)
        expect(result[:win_rate]).to eq(0.0)
        expect(result[:profit_count]).to eq(0)
        expect(result[:loss_count]).to eq(0)
        expect(result[:trade_count]).to eq(0)
        expect(result[:max_profit]).to eq(0.0)
        expect(result[:max_loss]).to eq(0.0)
        expect(result[:total_gross_profit]).to eq(0.0)
        expect(result[:total_net_profit]).to eq(0.0)
        expect(result[:avg_profit_loss_ratio]).to eq(0.0)
        expect(result[:max_profit_loss_ratio]).to eq(0.0)
        expect(result[:total_commission]).to eq(0.0)
        expect(result[:total_tax]).to eq(0.0)
        expect(result[:max_consecutive_losses]).to eq(0)
      end
    end
  end
end
