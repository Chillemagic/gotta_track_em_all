class AddHoloTypeToSearchAttempt < ActiveRecord::Migration[8.1]
  def change
    add_column :search_attempts, :holo_type, :string
  end
end
