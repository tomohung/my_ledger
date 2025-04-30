# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  risk_settings   :text             default({}), not null
#  initial_capital :decimal(10, 2)   default(0.0), not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :trade_logs, dependent: :destroy
  has_many :broker_accounts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  store :risk_settings, accessors: [
    :risk_amount_percentage_per_trade,
    :risk_amount_percentage_per_day,
    :risk_amount_percentage_per_week,
    :risk_amount_percentage_per_month
  ], coder: JSON

  after_initialize :set_default_risk_settings, if: :new_record?
  after_initialize :set_default_initial_capital, if: :new_record?

  def name
    email_address.split("@").first
  end

  private

  def set_default_risk_settings
    return if risk_settings.present?

    self.risk_settings = {
      risk_amount_percentage_per_trade: 2.0,
      risk_amount_percentage_per_day: 5.0,
      risk_amount_percentage_per_week: 10.0,
      risk_amount_percentage_per_month: 20.0
    }
  end

  def set_default_initial_capital
    return if initial_capital.present?

    self.initial_capital = 100_000
  end
end
