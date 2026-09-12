class AddFetchPricingStatusToSearchAttempt < ActiveRecord::Migration[8.1]
  def change
    add_column :search_attempts, :fetch_pricing_status, :string, null: false, default: "standby"
  end
end
