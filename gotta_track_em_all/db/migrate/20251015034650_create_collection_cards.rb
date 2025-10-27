class CreateCollectionCards < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_cards do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :cards, null: false, foreign_key: true
      t.decimal :purchase_price
      t.string :condition
      t.text :notes

      t.timestamps
    end
  end
end
