class RemovePokemonSetFromCards < ActiveRecord::Migration[8.0]
  def change
    remove_column :cards, :pokemon_set
  end
end
