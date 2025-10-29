class FetchCardPricingJob < ApplicationJob
  queue_as :default

  retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(card_id)
    # 1. Find Card from existing card db
    puts "Running FetchCardPricingJob"
    card = Card.find(card_id)

    set_name = card.set_name

    if set_name == "McDonald's Collection 2021"
      set_name = "McDonald’s 25th Anniversary"
    end

    # 2. find the api_id for pokedata API
    search_response = HTTParty.get("https://www.pokedata.io/v0/search",
      query: { query: card.name, asset_type: "CARD" },
      timeout: 30
    )

    # Check if the search was successful
    return { error: "API failed" } unless response.success?
    # Parse the api response
    search_results = search_response.parsed_response
    # Find the matching card

    matching_card = search_results.find { |result| result["set_name"] == set_name && result["num"].to_s == card.card_number.to_s }

    return { error: "No matching card found" } if matching_card.nil?

    # 3. Call Pokedata price using card.id
    pricing_response = HTTParty.get(
      "https://www.pokedata.io/v0/pricing",
      query: { id: matching_card["id"], asset_type: "CARD" },
      timeout: 30
    )

    unless pricing_response.success?
      Rails.logger.error("PokeData pricing failed: #{pricing_response.code}")
      return
    end

    pricing_data = pricing_response.parsed_response
    # 4. Create price history for card
    card.update!(
      pokedata_id: matching_card["id"],
      card_number: pricing_data["num"],
      release_date: pricing_data["release_date"],
      set_name: pricing_data["set_name"]
    )

    PriceHistory.create!(
      cards_id: card.id,
      pokedata_id: pricing_data["id"],
      card_name: pricing_data["name"],
      card_number: pricing_data["num"],
      set_name: pricing_data["set_name"],
      release_date: pricing_data["release_date"],
      secret: pricing_data["secret"],
      pricing_data: pricing_data["pricing"],
      pokedata_raw_price: pricing_data.dig("pricing", "Pokedata Raw", "value"),
      source: "Pokedata",
      recorded_at: Time.current
    )

    Rails.logger.info("Successfully created price history for card #{card.id}")

    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Card #{card_id} not found")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch pricing for card #{card_id}: #{e.message}")
      raise
  end
end
