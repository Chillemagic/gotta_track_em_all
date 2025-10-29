class ChangeCardNumberToBeStringInCards < ActiveRecord::Migration[8.0]
  def change
    change_column :cards, :card_number, :string
  end
end
