# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  password_digest :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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

  def name
    email_address.split("@").first
  end
end
