class Card < ApplicationRecord
  has_many :collection_cards, dependent: :destroy
  has_many :collections, through: :collection_cards
  has_many :price_histories, dependent: :destroy
  has_one_attached :image

  # validates :card_api_id, presence: true, uniqueness: true
  validates :name, presence: true

  after_update_commit -> {
    Rails.logger.info "🔔 Broadcasting update for card #{id}"

    broadcast_replace_to(
      "card_#{id}",
      target: "card_#{id}",
      partial: "cards/card_info",
      locals: { card: self }
    )
  }

  enum :api_tcg_status, { pending: "pending", incomplete: "incomplete", complete: "complete" }, prefix: true
  enum :tcg_dex_status, { pending: "pending", incomplete: "incomplete", complete: "complete" }, prefix: true

  ESSENTIAL_FIELDS = %i[artist image_url rarity set_name].freeze

  def condition_options
    pricing_history = @card.price_histories.last
    if pricing_history
      pricing_hash = pricing_history.attributes["pricing_data"]
      grading_keys = pricing_hash.keys
                                 .select { |k| k.match?(/\A(PSA|CGC)\s*\d+(\.\d+)?\z/) }
                                 .sort_by { |k| k[/\d+(\.\d+)?/].to_f }
      raw_keys = pricing_hash.keys.select { |k| k.downcase.include?("raw") }
      @condition_options = raw_keys + grading_keys
    else
      @condition_options = ["Raw"] + (1..10).flat_map { |n| ["CGC #{n}.0", "PSA #{n}.0"] }
    end
  end

  def complete_card_info?
    ESSENTIAL_FIELDS.all? { |field| send(field).present? }
  end

  def missing_fields
    ESSENTIAL_FIELDS.select { |field| send(field).blank? }
  end

  def simulate_price_update!
    # Random new price
    new_price = (rand * 20).round(2)

    # Save to price_histories (optional)
    price_histories.create!(pokedata_raw_price: new_price)

    # Broadcast the updated card to the view
    Turbo::StreamsChannel.broadcast_replace_to(
      "card_#{id}",
      target: "card_#{id}",
      partial: "cards/card_info",
      locals: { card: self }
    )
  end
end
