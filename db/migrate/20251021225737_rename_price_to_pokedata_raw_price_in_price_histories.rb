class RenamePriceToPokedataRawPriceInPriceHistories < ActiveRecord::Migration[8.0]
  def change
    rename_column :price_histories, :price, :pokedata_raw_price
  end
end
