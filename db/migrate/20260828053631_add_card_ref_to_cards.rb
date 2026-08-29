class AddCardRefToCards < ActiveRecord::Migration[8.1]
  def change
    add_reference :cards, :card, null: false, foreign_key: true
  end
end
