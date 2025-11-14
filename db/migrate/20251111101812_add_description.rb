class AddDescription < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_cards, :description, :text
  end
end
