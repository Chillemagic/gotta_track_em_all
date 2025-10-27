class CreatePriceHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :price_histories do |t|
      t.references :cards, null: false, foreign_key: true
      t.decimal :price
      t.string :source
      t.date :recorded_at

      t.timestamps
    end
  end
end
