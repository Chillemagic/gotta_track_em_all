class CreateCollectionCards < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_cards do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
