class AddRiskSettingsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :risk_settings, :text, null: false, default: "{}"
  end
end
