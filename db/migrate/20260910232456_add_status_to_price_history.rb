class AddStatusToPriceHistory < ActiveRecord::Migration[8.1]
  def change
    add_column :price_histories, :status, :string, null: false, default: "pending"
  end
end
