class AddUniqueIndexToCardsApiTcgId < ActiveRecord::Migration[8.1]
  def change
    add_index :cards,
              :api_tcg_id,
              unique: true,
              where: "api_tcg_id IS NOT NULL"
  end 
end
