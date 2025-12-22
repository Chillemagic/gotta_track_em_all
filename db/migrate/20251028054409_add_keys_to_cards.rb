class AddKeysToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :api_tcg_id, :integer
    add_column :cards, :language, :string
  end
end
