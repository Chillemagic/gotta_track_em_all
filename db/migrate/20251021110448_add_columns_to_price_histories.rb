class AddColumnsToPriceHistories < ActiveRecord::Migration[8.0]
  def change
    add_column :price_histories, :pricing_data, :jsonb
    add_column :price_histories, :pokedata_id, :string
    add_column :price_histories, :card_name, :string
    add_column :price_histories, :card_number, :string
    add_column :price_histories, :pokemon_set, :string
    add_column :price_histories, :release_date, :date
    add_column :price_histories, :secret, :boolean
  end
end
