# == Schema Information
#
# Table name: trade_logs
#
#  id             :integer          not null, primary key
#  trade_date     :date
#  product_name   :string
#  contract_month :string
#  position       :string
#  quantity       :integer
#  entry_price    :decimal(10, 2)
#  exit_price     :decimal(10, 2)
#  gross_pnl      :decimal(10, 2)
#  commission     :decimal(10, 2)
#  tax            :decimal(10, 2)
#  net_pnl        :decimal(10, 2)
#  currency       :string
#  entry_order_id :string
#  exit_order_id  :string
#  raw_csv_data   :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_id        :integer          not null
#
# Indexes
#
#  index_trade_logs_on_contract_month  (contract_month)
#  index_trade_logs_on_product_name    (product_name)
#  index_trade_logs_on_trade_date      (trade_date)
#  index_trade_logs_on_user_id         (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
class TradeLog < ApplicationRecord
  belongs_to :user
end
