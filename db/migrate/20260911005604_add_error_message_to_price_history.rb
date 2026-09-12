class AddErrorMessageToPriceHistory < ActiveRecord::Migration[8.1]
  def change
    add_column :price_histories, :error_message, :string
  end
end
