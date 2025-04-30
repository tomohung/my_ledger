class UsersController < ApplicationController
  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to edit_user_path, notice: "Settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :initial_capital,
      :risk_amount_percentage_per_trade,
      :risk_amount_percentage_per_day,
      :risk_amount_percentage_per_week,
      :risk_amount_percentage_per_month
    )
  end
end
