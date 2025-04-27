# == Schema Information
#
# Table name: broker_accounts
#
#  id             :integer          not null, primary key
#  name           :string
#  account_number :string
#  broker         :string
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_broker_accounts_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class BrokerAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
