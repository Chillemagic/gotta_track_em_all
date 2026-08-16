class AddIdentifyCardJobStatusToCards < ActiveRecord::Migration[8.1]
  def change
    add_column :cards, :status, :string, default: 'processing'
  end
end
