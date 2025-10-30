class RenameCardsIdToCardIdInCollectionCards < ActiveRecord::Migration[8.0]
  def change
    rename_column :collection_cards, :cards_id, :card_id
  end
end
