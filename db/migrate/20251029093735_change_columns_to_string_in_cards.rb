class ChangeColumnsToStringInCards < ActiveRecord::Migration[8.0]
  def change
    change_column :cards, :api_tcg_id, :string
    change_column :cards, :pokedata_id, :string
  end
end
