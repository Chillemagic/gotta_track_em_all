class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_cards, dependent: :destroy
  has_many :cards, through: :collection_cards

  validates :name, presence: true
end
