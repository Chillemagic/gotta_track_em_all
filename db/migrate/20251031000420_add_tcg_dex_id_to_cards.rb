class AddTcgDexIdToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :tcgdex_id, :string
  end
end
