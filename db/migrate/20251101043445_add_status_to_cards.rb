class AddStatusToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :api_tcg_status, :string
    add_column :cards, :tcg_dex_status, :string
  end
end
