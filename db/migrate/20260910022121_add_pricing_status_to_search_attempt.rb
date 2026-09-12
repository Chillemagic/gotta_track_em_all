class AddPricingStatusToSearchAttempt < ActiveRecord::Migration[8.1]
  def change
    add_column :search_attempts, :pricing_status, :string
  end
end
