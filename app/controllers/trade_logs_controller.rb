class TradeLogsController < ApplicationController
  def new
  end

  def create
    csv_content = params[:csv_content]

    if csv_content.blank?
      flash.now[:alert] = "請貼上 CSV 內容"
      render :new
      return
    end

    result = TradeLog.import_from_csv_string(csv_content)

    if result[:success]
      flash[:notice] = "成功匯入 #{result[:imported_count]} 筆交易資料，失敗 #{result[:failed_count]} 筆。"
      redirect_to new_trade_log_path
    else
      flash.now[:alert] = "匯入失敗: #{result[:error_message]}"
      render :new
    end
  end
end
