class PriceHistory < ApplicationRecord
  belongs_to :card, touch: true

  validates :pokedata_raw_price, presence: true, numericality:  { greater_than_or_equal_to: 0 }
  validates :source, presence: true
  validates :recorded_at, presence: true
end
