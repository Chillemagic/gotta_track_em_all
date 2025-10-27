class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.integer :card_api_id
      t.string :name
      t.integer :card_number
      t.string :pokemon_set
      t.date :release_date
      t.string :artist
      t.string :rarity
      t.string :image_url
      t.string :pokemon_types
      t.string :finish_type

      t.timestamps
    end
  end
end
