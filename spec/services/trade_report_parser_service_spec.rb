require "rails_helper"

RSpec.describe TradeReportParserService do
  describe "#parse" do
    context "with futures trading system format" do
      let(:futures_csv) do
        <<~CSV
          帳號,商品名稱,委託種類,買賣別,委託價,成交均價,原委託量,成交數量,交易日期,成交時間,委託序號,來源別,網路單號,
          ="022-0055408",="小台指05",="平倉ROD",="限買","20,665",="20665","1","1",="2025/05/09",="10:01:18",="yaaO7",="I",="2160000848101",
          ="022-0055408",="小台指05",="平倉IOC",="市買","20,725",="20624","1","1",="2025/05/09",="09:40:20",="yaaHO",="I",="2160000727101",
          ="022-0055408",="小台指05",="新倉ROD",="限賣","20,800",="20800","1","1",="2025/05/09",="09:35:15",="yaaG5",="I",="2160000705101"
        CSV
      end

      let(:service) { described_class.new(futures_csv) }
      let(:trades) { service.parse }

      it "parses the correct number of trades" do
        expect(trades.size).to eq(3)
      end

      it "correctly parses the first trade" do
        trade = trades[0]
        expect(trade.type).to eq("平倉")
        expect(trade.direction).to eq("買")
        expect(trade.price).to eq(20665.0)
        expect(trade.quantity).to eq(1)
        expect(trade.date).to eq("2025/05/09")
        expect(trade.time).to eq("10:01:18")
      end

      it "correctly parses the last trade" do
        trade = trades[2]
        expect(trade.type).to eq("新倉")
        expect(trade.direction).to eq("賣")
        expect(trade.price).to eq(20800.0)
        expect(trade.quantity).to eq(1)
        expect(trade.date).to eq("2025/05/09")
        expect(trade.time).to eq("09:35:15")
      end
    end

    context "with options trading system format" do
      let(:options_csv) do
        <<~CSV
          帳號,商品,種類,買賣別,委託價,成交均價,委託量,成交量,交易日期,成交時間,委託序號,來源別,
          ="022-0055408 期權",="小台指05",="平倉IOC",="市賣","20,996","21,100","1","1",="2025/05/12",="10:47:32",="yabdx",="I",
          ="022-0055408 期權",="小台指05",="新倉ROD",="限買","21,116","21,116","1","1",="2025/05/12",="10:36:11",="yabbG",="I",
          ="022-0055408 期權",="新倉IOC",="市賣","21,200","21,150","1","1",="2025/05/12",="10:30:05",="yab9X",="I"
        CSV
      end

      let(:service) { described_class.new(options_csv) }
      let(:trades) { service.parse }

      it "parses the correct number of trades" do
        expect(trades.size).to eq(3)
      end

      it "correctly parses the first trade" do
        trade = trades[0]
        expect(trade.type).to eq("平倉")
        expect(trade.direction).to eq("賣")
        expect(trade.price).to eq(21100.0)
        expect(trade.quantity).to eq(1)
        expect(trade.date).to eq("2025/05/12")
        expect(trade.time).to eq("10:47:32")
      end

      it "correctly parses the last trade" do
        trade = trades[2]
        expect(trade.type).to eq("新倉")
        expect(trade.direction).to eq("賣")
        expect(trade.price).to eq(21150.0)
        expect(trade.quantity).to eq(1)
        expect(trade.date).to eq("2025/05/12")
        expect(trade.time).to eq("10:30:05")
      end
    end

    context "with empty CSV content" do
      let(:service) { described_class.new("") }
      let(:trades) { service.parse }

      it "returns an empty array" do
        expect(trades).to be_empty
      end
    end

    context "with CSV content containing BOM" do
      let(:csv_with_bom) do
        "\uFEFF帳號,商品名稱,委託種類,買賣別,委託價,成交均價,原委託量,成交數量,交易日期,成交時間,委託序號,來源別,網路單號,\n" \
        "=\"022-0055408\",=\"小台指05\",=\"平倉ROD\",=\"限買\",\"20,665\",=\"20665\",\"1\",\"1\",=\"2025/05/09\",=\"10:01:18\",=\"yaaO7\",=\"I\",=\"2160000848101\","
      end

      let(:service) { described_class.new(csv_with_bom) }
      let(:trades) { service.parse }

      it "successfully removes BOM and parses the content" do
        expect(trades.size).to eq(1)
        trade = trades[0]
        expect(trade.type).to eq("平倉")
        expect(trade.direction).to eq("買")
        expect(trade.price).to eq(20665.0)
      end
    end
  end
end
