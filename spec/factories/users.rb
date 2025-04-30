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
FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
