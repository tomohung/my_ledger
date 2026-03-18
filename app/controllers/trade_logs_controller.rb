class TradeLogsController < ApplicationController
  include Pagy::Method

  before_action :set_broker_account, only: [:create]
  before_action :set_trade_log, only: [:destroy]

  def index
    @pagy, @trade_logs = pagy(
      current_user.trade_logs
        .includes(:broker_account)
        .order(trade_date: :desc)
    )
  end

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
      @broker_accounts = current_user.broker_accounts
      render :new
    end
  end

  def destroy
    @trade_log.destroy
    flash[:notice] = "交易紀錄已刪除"
    redirect_to trade_logs_path
  end

  def batch_destroy
    ids = Array(params[:ids])
    trade_logs = current_user.trade_logs.where(id: ids)
    count = trade_logs.count
    trade_logs.destroy_all
    flash[:notice] = "已刪除 #{count} 筆交易紀錄"
    redirect_to trade_logs_path
  end

  private

  def set_broker_account
    @broker_account = current_user.broker_accounts.find(params[:broker_account_id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "券商帳戶不存在"
    redirect_to new_trade_log_path
  end

  def set_trade_log
    @trade_log = current_user.trade_logs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "交易紀錄不存在"
    redirect_to trade_logs_path
  end
end
