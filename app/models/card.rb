class Card < ApplicationRecord
  has_many :collection_cards, dependent: :destroy
  has_many :collections, through: :collection_cards
  has_many :price_histories, dependent: :destroy
  has_one_attached :image

  # validates :card_api_id, presence: true, uniqueness: true
  validates :name, presence: true

  ESSENTIAL_FIELDS = %i[artist image_url rarity set_name].freeze




  def complete_card_info?
    ESSENTIAL_FIELDS.all? { |field| send(field).present? }
  end

  def missing_fields
    ESSENTIAL_FIELDS.select { |field| send(field).blank? }
  end
end
