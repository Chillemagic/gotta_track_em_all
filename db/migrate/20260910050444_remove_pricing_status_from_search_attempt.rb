class RemovePricingStatusFromSearchAttempt < ActiveRecord::Migration[8.1]
  def change
    remove_column :search_attempts, :pricing_status, :string
  end
end
