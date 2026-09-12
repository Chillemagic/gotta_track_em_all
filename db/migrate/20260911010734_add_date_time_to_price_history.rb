class AddDateTimeToPriceHistory < ActiveRecord::Migration[8.1]
  def change
      change_column :price_histories, :recorded_at, :datetime
  end
end
