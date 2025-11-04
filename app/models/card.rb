class Card < ApplicationRecord
  has_many :collection_cards, dependent: :destroy
  has_many :collections, through: :collection_cards
  has_many :price_histories, foreign_key: "cards_i", dependent: :destroy
  has_one_attached :image

  # validates :card_api_id, presence: true, uniqueness: true
  validates :name, presence: true
end
