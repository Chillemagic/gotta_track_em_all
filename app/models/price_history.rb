class PriceHistory < ApplicationRecord
  belongs_to :card

  validates :price, presence: true, numericality:  { greater_than_or_equal_to: 0 }
  validates :source, presence: true
  validates :recorded_at, presence: true
end
