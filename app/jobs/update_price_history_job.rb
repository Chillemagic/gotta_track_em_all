class UpdatePriceHistoryJob < ApplicationJob

  def perform(card_id)

    card = Card.find(card_id)

    # Check if a price history has been pulled in the last 24 hours
    last_update = card.price_histories.order(recorded_at: :desc).first
    if last_update && last_update.recorded_at >= Date.current
      Rails.logger.info("Price history for card #{card_id} was updated today, skipping")
      return
    end

    pricing_response = HTTParty.get(
      "https://www.pokedata.io/v0/pricing",
      query: { id: card.pokedata_id, asset_type: "CARD" },
      headers: { "Authorization" => "Bearer #{ENV["POKEDATA_API_KEY"]}" },
      timeout: 30
    )

    unless pricing_response.success?
      Rails.logger.error("PokeData pricing failed: #{pricing_response.code}")
      return
    end

    pricing_data = pricing_response.parsed_response
    pricing = pricing_data["pricing"]

    # Collect all PSA pricing
    psa_pricing = pricing.select { |key, _value| key.start_with?("PSA") }
    # Collect all CGC pricing
    cgc_pricing = pricing.select { |key, _value| key.start_with?("CGC") }

    # Check card.card_number
    card.price_histories.create!(
      pokedata_id: pricing_data["id"],
      card_name: pricing_data["name"],
      card_number: card.card_number,
      set_name: pricing_data["set_name"],
      release_date: pricing_data["release_date"],
      secret: pricing_data["secret"],
      psa_pricing: psa_pricing,
      cgc_pricing: cgc_pricing,
      pricing_data: pricing_data["pricing"],
      pokedata_raw_price: pricing_data.dig("pricing", "Pokedata Raw", "value"),
      source: "Pokedata",
      recorded_at: Time.current
    )

    Rails.logger.info("Successfully created price history for card #{card.id}")

  rescue ActiveRecord::RecordNotFound
    Rails.logger.error("Card #{card_id} not found")
  rescue HTTParty::Error => e
    Rails.logger.error("HTTP error fetching pricing for card #{card_id}: #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("Failed to fetch pricing for card #{card_id}: #{e.message}")
    raise
  end
end
