require "rails_helper"

RSpec.describe "TradeSummaries", type: :request do
  let(:user) { create(:user, initial_capital: 500_000) }
  let(:broker_account) { create(:broker_account, user: user) }

  before { sign_in(user) }

  describe "GET /trade_summaries/daily" do
    it "renders successfully with no trades" do
      get daily_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with trades" do
      create(:trade_log, user: user, broker_account: broker_account, trade_date: Date.today)
      get daily_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with a specific date" do
      get daily_trade_summaries_path(date: "2025-01-15")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /trade_summaries/weekly" do
    it "renders successfully with no trades" do
      get weekly_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with trades" do
      create(:trade_log, user: user, broker_account: broker_account, trade_date: Date.today)
      get weekly_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /trade_summaries/monthly" do
    it "renders successfully with no trades" do
      get monthly_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with trades" do
      create(:trade_log, user: user, broker_account: broker_account, trade_date: Date.today)
      create(:trade_log, :losing, user: user, broker_account: broker_account, trade_date: Date.today - 1.day)
      get monthly_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /trade_summaries/overall" do
    it "renders successfully with no trades" do
      get overall_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with trades" do
      create(:trade_log, user: user, broker_account: broker_account, trade_date: Date.today)
      get overall_trade_summaries_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with date range" do
      get overall_trade_summaries_path(start_date: "2025-01-01", end_date: "2025-01-31")
      expect(response).to have_http_status(:ok)
    end
  end

  describe "trade type filter" do
    it "renders daily with futures filter" do
      get daily_trade_summaries_path(trade_type: "futures")
      expect(response).to have_http_status(:ok)
    end

    it "renders daily with options filter" do
      get daily_trade_summaries_path(trade_type: "options")
      expect(response).to have_http_status(:ok)
    end
  end
end
