class AddDefaultToConditionInCollectionCards < ActiveRecord::Migration[8.0]
  def change
    change_column_default :collection_cards, :condition, "Poor"
  end
end
