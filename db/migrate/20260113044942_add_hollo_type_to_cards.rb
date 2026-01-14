class AddHolloTypeToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :holo_type, :string
  end
end
