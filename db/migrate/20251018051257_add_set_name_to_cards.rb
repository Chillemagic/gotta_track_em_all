class AddSetNameToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :set_name, :string
  end
end
