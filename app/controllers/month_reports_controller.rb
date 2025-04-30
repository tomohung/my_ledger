class MonthReportsController < ApplicationController
  include Pagy::Backend
  before_action :set_selected_date, only: [:show]

  def show
    @month_report = MonthReport.generate_for_month(current_user, @selected_date.beginning_of_month)
  end

  private

  def set_selected_date
    @selected_date = params[:id]&.to_date || Date.today
  end
end
