class SearchAttempt < ActiveRecord::Migration[8.1]
  def change
    create_table :search_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :card, null: true, foreign_key: true

      t.string :status, null: false, default: "pending"
      t.string :provider, null: false, default: "openai"

      t.string :identified_name
      t.string :identified_number
      t.string :identified_set_name
      t.string :identified_rarity
      t.string :identified_moves
      t.string :identified_language
      t.boolean :identified_staff

      t.text :error_message
      t.timestamps
    end
  end
end
