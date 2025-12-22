class AddFieldsToPriceHistories < ActiveRecord::Migration[8.0]
  def change
    add_column :price_histories, :cgc_pricing, :jsonb, default: {}
    add_column :price_histories, :psa_pricing, :jsonb, default: {}
    rename_column :price_histories, :cards_id, :card_id
  end
end
