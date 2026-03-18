require "rails_helper"

RSpec.describe "TradeLogs", type: :request do
  let(:user) { create(:user) }
  let(:broker_account) { create(:broker_account, user: user) }

  before { sign_in(user) }

  describe "GET /trade_logs" do
    it "renders successfully with no trades" do
      get trade_logs_path
      expect(response).to have_http_status(:ok)
    end

    it "renders successfully with trades" do
      create_list(:trade_log, 3, user: user, broker_account: broker_account)
      get trade_logs_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /trade_logs/new" do
    it "renders successfully" do
      get new_trade_log_path
      expect(response).to have_http_status(:ok)
    end
  end
end
