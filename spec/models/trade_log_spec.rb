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
#
# Indexes
#
#  index_trade_logs_on_broker_account_id  (broker_account_id)
#  index_trade_logs_on_contract_month     (contract_month)
#  index_trade_logs_on_product_name       (product_name)
#  index_trade_logs_on_trade_date         (trade_date)
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
      # Set the current user and broker account for the test
      allow_any_instance_of(TradeLog).to receive(:user).and_return(user)
      allow_any_instance_of(TradeLog).to receive(:broker_account).and_return(broker_account)
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
      expect(first_trade.broker_account).to eq(broker_account)

      # Verify last trade log
      second_trade = TradeLog.last
      expect(second_trade.trade_date).to eq(Date.parse("2025-04-28"))
      expect(second_trade.product_name).to eq("小台指")
      expect(second_trade.contract_month).to eq("202505")
      expect(second_trade.buy_quantity).to eq(0)
      expect(second_trade.sell_quantity).to eq(1)
      expect(second_trade.price).to eq(19999)
      expect(second_trade.gross_pnl).to eq(0)
      expect(second_trade.commission).to eq(20)
      expect(second_trade.tax).to eq(20)
      expect(second_trade.net_pnl).to eq(0)
      expect(second_trade.currency).to eq("TWD")
      expect(second_trade.order_id).to eq("yaays")
      expect(second_trade.user).to eq(user)
      expect(second_trade.broker_account).to eq(broker_account)
    end

    it "skips header and summary rows" do
      TradeLog.import_from_csv_string(broker_account, csv_data)
      expect(TradeLog.count).to eq(4)
    end
  end
end
