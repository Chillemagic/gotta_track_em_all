class PriceHistory < ApplicationRecord
  belongs_to :card, touch: true

  validates :pokedata_raw_price, presence: true, numericality:  { greater_than_or_equal_to: 0 }
  validates :source, presence: true
  validates :recorded_at, presence: true

  enum :status, {
    pending: "pending",
    fetching: "fetching", # When the pricing job is initiated
    matched: "matched", # If an exisitng record less than 24 hours is found
    unavailable: "unavailable", # When the API doe not find any pricing data
    complete: "complete", # When the job is complete
    failed: "failed" # When the job fails
  }, prefix: true
end
