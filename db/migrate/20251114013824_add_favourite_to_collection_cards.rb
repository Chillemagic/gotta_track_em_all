class AddFavouriteToCollectionCards < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_cards, :favourite, :boolean, default: false
  end
end
