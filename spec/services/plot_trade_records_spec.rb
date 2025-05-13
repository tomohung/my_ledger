require "rails_helper"

RSpec.describe PlotTradeRecords do
  describe "#call" do
    let(:trades) do
      [
        double("Trade", type: "新倉", direction: "買", price: 20700, quantity: 2, date: "2025/05/09", time: "08:48:14"),
        double("Trade", type: "平倉", direction: "賣", price: 20800, quantity: 1, date: "2025/05/09", time: "09:15:30"),
        double("Trade", type: "新倉", direction: "賣", price: 20900, quantity: 3, date: "2025/05/09", time: "09:16:00")
      ]
    end

    context "without merging" do
      let(:service) { described_class.new(trades) }
      let(:result) { service.call }

      it "generates correct PineScript code" do
        expect(result).to include("showBuys = input.bool(true, \"Show Buy Signals\")")
        expect(result).to include("showSells = input.bool(true, \"Show Sell Signals\")")
        expect(result).to include("buyColor = input.color(color.red, \"Buy Signal Color\")")
        expect(result).to include("sellColor = input.color(color.green, \"Sell Signal Color\")")
        expect(result).to include("closeColor = input.color(color.gray, \"Close Signal Color\")")

        # Check first trade
        expect(result).to include("timestamp(2025, 05, 09, 08, 48, 14)")
        expect(result).to include("plotshape(open0_condition ? 20700 : na")
        expect(result).to include('text="buy 20700 x2"')

        # Check second trade
        expect(result).to include("timestamp(2025, 05, 09, 09, 15, 30)")
        expect(result).to include("plotshape(close1_condition ? 20800 : na")
        expect(result).to include('text="sell 20800 x1"')
      end
    end

    context "with merging to 5 minutes" do
      let(:trades) do
        [
          double("Trade", type: "新倉", direction: "買", price: 20700, quantity: 2, date: "2025/05/09", time: "09:15:00"),
          double("Trade", type: "新倉", direction: "買", price: 20750, quantity: 1, date: "2025/05/09", time: "09:15:30"),
          double("Trade", type: "新倉", direction: "買", price: 20800, quantity: 3, date: "2025/05/09", time: "09:20:00")
        ]
      end

      let(:service) { described_class.new(trades, merge_to_5min: true) }
      let(:result) { service.call }

      it "generates fewer plotshape calls" do
        # Should generate 2 plotshapes instead of 3
        expect(result.scan("plotshape").count).to eq(2)
      end

      it "merges trades within 5 minutes" do
        expect(result).to include("timestamp(2025, 05, 09, 09, 15, 00)")
        expect(result).to include("timestamp(2025, 05, 09, 09, 20, 00)")
      end

      it "shows total quantity for merged trades" do
        # First group (2 trades within 5 minutes)
        expect(result).to include('text="buy 20700 x3"') # 2 + 1
        # Second group (1 trade)
        expect(result).to include('text="buy 20800 x3"')
      end
    end

    context "with empty trades" do
      let(:service) { described_class.new([]) }
      let(:result) { service.call }

      it "returns empty string" do
        expect(result).to eq("")
      end
    end
  end
end
