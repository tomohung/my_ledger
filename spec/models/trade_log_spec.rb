# == Schema Information
#
# Table name: trade_logs
#
#  id                :integer          not null, primary key
#  trade_date        :date             not null
#  product_name      :string
#  contract_month    :string
#  price             :decimal(10, 2)
#  gross_pnl         :decimal(10, 2)
#  commission        :decimal(10, 2)
#  tax               :decimal(10, 2)
#  net_pnl           :decimal(10, 2)
#  currency          :string           not null
#  order_id          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :integer          not null
#  broker_account_id :integer          not null
#  buy_quantity      :integer
#  sell_quantity     :integer
#  strike_price      :decimal(10, 2)
#  call_put          :string
#  trade_type        :string           default("futures"), not null
#  trade_time        :string
#
# Indexes
#
#  index_trade_logs_on_broker_account_id  (broker_account_id)
#  index_trade_logs_on_contract_month     (contract_month)
#  index_trade_logs_on_product_name       (product_name)
#  index_trade_logs_on_trade_date         (trade_date)
#  index_trade_logs_on_trade_type         (trade_type)
#  index_trade_logs_on_user_id            (user_id)
#
# Foreign Keys
#
#  broker_account_id  (broker_account_id => broker_accounts.id)
#  user_id            (user_id => users.id)
#
require "rails_helper"

RSpec.describe TradeLog, type: :model do
  describe ".import_from_csv_string" do
    let(:user) { create(:user) }
    let(:session) { create(:session, user: user) }
    let(:broker_account) { create(:broker_account, user: user) }
    let(:csv_data) do
      <<~CSV
        項次,交易日期,商品名稱,年月,履約價格,C/P,結算價,買口數,賣口數,成交價格,權利金收支,損益,手續費,交易稅,淨損益,幣別,委託書號,
        ="1",="2025/04/28",="小台指",="202505",="",="",="0",="",="1",="19994",="",="-300",="20",="20",="-380",="TWD",="yaamT",
        ="",="2025/04/28",="小台指",="202505",="",="",="0",="1",="",="20000",="",="",="20",="20",="",="TWD",="yaauM",
        ="2",="2025/04/28",="小台指",="202505",="",="",="0",="1",="",="20000",="",="-50",="20",="20",="-130",="TWD",="yaauR",
        ="",="2025/04/28",="小台指",="202505",="",="",="0",="",="1",="19999",="",="",="20",="20",="",="TWD",="yaays",
        ="",="",="台幣小計",="",="",="",="",="17",="17",="",="",="-5000",="680",="680",="-6360",="",="",
      CSV
    end

    before do
      Current.session = session
    end

    it "creates trade logs from CSV data" do
      TradeLog.import_from_csv_string(broker_account, csv_data)

      # Verify first trade log
      first_trade = TradeLog.first
      expect(first_trade.trade_date).to eq(Date.parse("2025-04-28"))
      expect(first_trade.product_name).to eq("小台指")
      expect(first_trade.contract_month).to eq("202505")
      expect(first_trade.buy_quantity).to eq(0)
      expect(first_trade.sell_quantity).to eq(1)
      expect(first_trade.price).to eq(19994)
      expect(first_trade.gross_pnl).to eq(-300)
      expect(first_trade.commission).to eq(20)
      expect(first_trade.tax).to eq(20)
      expect(first_trade.net_pnl).to eq(-380)
      expect(first_trade.currency).to eq("TWD")
      expect(first_trade.order_id).to eq("yaamT")
      expect(first_trade.user).to eq(user)
      expect(first_trade.trade_type).to eq("futures")
      expect(first_trade.strike_price).to be_nil
      expect(first_trade.call_put).to be_nil
      expect(first_trade.broker_account).to eq(broker_account)

      # Verify last trade log
      second_trade = TradeLog.last
      expect(second_trade.trade_date).to eq(Date.parse("2025-04-28"))
      expect(second_trade.product_name).to eq("小台指")
      expect(second_trade.contract_month).to eq("202505")
      expect(second_trade.buy_quantity).to eq(0)
      expect(second_trade.sell_quantity).to eq(1)
      expect(second_trade.price).to eq(19999)
      expect(second_trade.gross_pnl).to eq(nil)
      expect(second_trade.commission).to eq(20)
      expect(second_trade.tax).to eq(20)
      expect(second_trade.net_pnl).to eq(nil)
      expect(second_trade.currency).to eq("TWD")
      expect(second_trade.order_id).to eq("yaays")
      expect(second_trade.user).to eq(user)
      expect(second_trade.broker_account).to eq(broker_account)
    end

    it "skips header and summary rows" do
      TradeLog.import_from_csv_string(broker_account, csv_data)
      expect(TradeLog.count).to eq(4)
    end

    context "with options data" do
      let(:options_csv_data) do
        <<~CSV
          項次,交易日期,商品名稱,年月,履約價格,C/P,結算價,買口數,賣口數,成交價格,權利金收支,損益,手續費,交易稅,淨損益,幣別,委託書號,
          ="1",="2025/04/28",="臺指選擇權",="202505",="20000",="C",="0",="1",="",="150",="",="500",="20",="10",="470",="TWD",="optA1",
          ="2",="2025/04/28",="臺指選擇權",="202505",="20000",="P",="0",="",="1",="100",="",="-200",="20",="10",="-230",="TWD",="optA2",
        CSV
      end

      it "imports options trades with strike_price and call_put" do
        TradeLog.import_from_csv_string(broker_account, options_csv_data)

        call_trade = TradeLog.find_by(order_id: "optA1")
        expect(call_trade.trade_type).to eq("options")
        expect(call_trade.strike_price).to eq(20000)
        expect(call_trade.call_put).to eq("C")

        put_trade = TradeLog.find_by(order_id: "optA2")
        expect(put_trade.trade_type).to eq("options")
        expect(put_trade.strike_price).to eq(20000)
        expect(put_trade.call_put).to eq("P")
      end
    end
  end

  describe ".detect_csv_format" do
    it "returns :trade_time when headers contain 委託序號 and 成交時間" do
      csv = "委託序號,成交時間,商品名稱\n12345,08:45:01,小台指\n"
      expect(TradeLog.detect_csv_format(csv)).to eq(:trade_time)
    end

    it "returns :import for standard import CSV" do
      csv = "項次,交易日期,商品名稱,年月,履約價格,C/P,結算價,買口數,賣口數,成交價格,權利金收支,損益,手續費,交易稅,淨損益,幣別,委託書號,\n"
      expect(TradeLog.detect_csv_format(csv)).to eq(:import)
    end
  end

  describe ".update_times_from_csv_string" do
    let(:user) { create(:user) }
    let(:broker_account) { create(:broker_account, user: user) }
    let!(:trade1) { create(:trade_log, user: user, broker_account: broker_account, order_id: "ABC01") }
    let!(:trade2) { create(:trade_log, user: user, broker_account: broker_account, order_id: "ABC02") }

    let(:csv_data) do
      <<~CSV
        委託序號,成交時間,商品名稱
        ABC01,08:45:01,小台指
        ABC02,09:00:15,小台指
        ABC99,10:00:00,小台指
      CSV
    end

    it "updates trade_time for matching order_ids" do
      result = TradeLog.update_times_from_csv_string(user, csv_data)

      expect(result[:updated_count]).to eq(2)
      expect(result[:not_found_count]).to eq(1)
      expect(result[:failure_count]).to eq(0)

      expect(trade1.reload.trade_time).to eq("08:45:01")
      expect(trade2.reload.trade_time).to eq("09:00:15")
    end

    it "does not update trades belonging to other users" do
      other_user = create(:user)
      other_broker = create(:broker_account, user: other_user)
      create(:trade_log, user: other_user, broker_account: other_broker, order_id: "ABC01")

      result = TradeLog.update_times_from_csv_string(other_user, csv_data)
      expect(result[:updated_count]).to eq(1)
      expect(trade1.reload.trade_time).to be_nil
    end

    it "updates all trades with the same order_id" do
      trade1_dup = create(:trade_log, user: user, broker_account: broker_account, order_id: "ABC01")
      csv = "委託序號,成交時間,商品名稱\nABC01,08:45:01,小台指\n"

      result = TradeLog.update_times_from_csv_string(user, csv)
      expect(result[:updated_count]).to eq(2)
      expect(trade1.reload.trade_time).to eq("08:45:01")
      expect(trade1_dup.reload.trade_time).to eq("08:45:01")
    end

    it "handles Excel-style formatted CSV" do
      excel_csv = "委託序號,成交時間,商品名稱\n=\"ABC01\",=\"08:45:01\",=\"小台指\"\n"
      result = TradeLog.update_times_from_csv_string(user, excel_csv)
      expect(result[:updated_count]).to eq(1)
      expect(trade1.reload.trade_time).to eq("08:45:01")
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let(:broker_account) { create(:broker_account, user: user) }

    let!(:futures_trade) { create(:trade_log, user: user, broker_account: broker_account, trade_type: "futures") }
    let!(:options_trade) { create(:trade_log, :options, user: user, broker_account: broker_account) }

    describe ".futures" do
      it "returns only futures trades" do
        expect(TradeLog.futures).to contain_exactly(futures_trade)
      end
    end

    describe ".options" do
      it "returns only options trades" do
        expect(TradeLog.options).to contain_exactly(options_trade)
      end
    end

    describe ".by_trade_type" do
      it "filters by given trade type" do
        expect(TradeLog.by_trade_type("futures")).to contain_exactly(futures_trade)
        expect(TradeLog.by_trade_type("options")).to contain_exactly(options_trade)
      end

      it "returns all when type is nil" do
        expect(TradeLog.by_trade_type(nil)).to contain_exactly(futures_trade, options_trade)
      end
    end
  end
end
