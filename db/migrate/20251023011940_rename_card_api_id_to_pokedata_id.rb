class RenameCardApiIdToPokedataId < ActiveRecord::Migration[8.0]
  def change
    rename_column :cards, :card_api_id, :pokedata_id
  end
end
