class AddPricingToCollectionCards < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_cards, :condition, :string
    add_column :collection_cards, :price, :decimal
  end
end
