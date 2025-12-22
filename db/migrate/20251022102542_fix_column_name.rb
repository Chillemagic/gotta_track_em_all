class FixColumnName < ActiveRecord::Migration[8.0]
  def change
    rename_column :price_histories, :pokemon_set, :set_name
  end
end
