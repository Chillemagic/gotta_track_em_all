class Card < ApplicationRecord
  has_many :collection_cards, dependent: :destroy
  has_many :collections, through: :collection_cards
  has_many :price_histories, dependent: :destroy

  # validates :card_api_id, presence: true, uniqueness: true
  validates :name, presence: true
end


# (ruby) card[:id]
# nil
# (ruby) card["id"]
# 66
# (ruby) card_id =  card["id"]
# 66
# (ruby) card_id
# 66
# (ruby) card["name"]
# "Charizard GX"
# (ruby) card_name =  card["name"]
# "Charizard GX"
# (ruby) card_name
# "Charizard GX"
# (ruby) card_name
# "Charizard GX"
# (ruby) card["release_date"]
# "2019-08-23"
# (ruby) release_date = card["release_date"]
# "2019-08-23"
# (ruby) release_date
# "2019-08-23"
# (ruby) Card.create(name: card_name, release_date: release_date, api_id: card_id )
