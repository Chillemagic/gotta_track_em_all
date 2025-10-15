class Card < ApplicationRecord
  has_many :collection_cards, dependent: :destroy
  has_many :collections, through: :collection_cards
  has_many :price_histories, dependent: :destroy

  validates :card_api_id, presence: true, uniqueness: true
  valdiates :name, presence: true
end
