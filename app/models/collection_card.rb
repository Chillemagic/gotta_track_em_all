class CollectionCard < ApplicationRecord
  belongs_to :collection
  belongs_to :card
  has_many :price_histories, through: :card

  after_initialize :set_default_condition, if: :new_record?

  def fetch_price
    latest_price_history = price_histories.order(:created_at).last
    return nil if latest_price_history.nil?
    if condition.match?("Raw")
      #Grab Pokedata raw price
      latest_price_history.pricing_data.dig("Pokedata Raw", "value").to_f.round(2)
    elsif condition.match?("CGC")
      # Grab CGC Pricing
      latest_price_history.cgc_pricing.dig(condition, "value").to_f.round(2)
    elsif condition.match?("PSA")
      latest_price_history.psa_pricing.dig(condition, "value").to_f.round(2)
    end
  end
  private

  def set_default_condition
    self.condition ||= "Poor"
  end
end
