class CollectionCard < ApplicationRecord
  belongs_to :collection
  belongs_to :card

  validates :card_id
end
