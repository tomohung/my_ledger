class TradeLogsController < ApplicationController
  before_action :set_broker_account, only: [:create]

  def new
    @broker_accounts = current_user.broker_accounts
  end

  def create
    csv_content = params[:csv_content]

    if csv_content.blank?
      flash.now[:alert] = "請貼上 CSV 內容"
      render :new
      return
    end

    result = TradeLog.import_from_csv_string(@broker_account, csv_content)

    if result[:success_count] > 0
      flash[:notice] = "成功匯入 #{result[:success_count]} 筆交易資料，失敗 #{result[:failure_count]} 筆。"
      redirect_to new_trade_log_path
    else
      flash.now[:alert] = "匯入失敗"
      render :new
    end
  end

  private

  def set_broker_account
    @broker_account = current_user.broker_accounts.find(params[:broker_account_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "券商帳戶不存在"
    redirect_to new_trade_log_path
  end
end
