class AddFieldsToSearchAttempts < ActiveRecord::Migration[8.1]
  def change
    add_column :search_attempts, :scrydex_status,
    :string,
    null: false,
    default: "not_requested"

    add_column :search_attempts, :scrydex_retried_at, :datetime
    add_column :search_attempts, :scrydex_card_id, :string
    add_column :search_attempts, :scrydex_error_message, :text
  end
end
