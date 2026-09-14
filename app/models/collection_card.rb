class CollectionCard < ApplicationRecord
  belongs_to :collection
  belongs_to :card
  has_many :price_histories, through: :card

  validates :condition, presence: true

  after_initialize :set_default_condition, if: :new_record?

  def fetch_price
    latest_price_history = price_histories.order(recorded_at: :desc, id: :desc).first
    return if latest_price_history.nil? || condition.blank?

    # The saved condition is the exact key, including its variant and grade flags.
    value = latest_price_history.pricing_data.to_h.dig(condition, "value")
    # Older histories stored graded prices only in the company-specific fields.
    value ||= latest_price_history.psa_pricing.to_h.dig(condition, "value")
    value ||= latest_price_history.cgc_pricing.to_h.dig(condition, "value")

    value.to_f.round(2) unless value.nil?
  end
  private

  def set_default_condition
    self.condition ||= "Poor"
  end
end
