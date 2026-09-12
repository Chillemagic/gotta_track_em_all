class AddScrydexRequestedAtToSearchAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :search_attempts, :scrydex_requested_at, :datetime
  end
end
