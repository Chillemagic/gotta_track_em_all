class FetchCardPricingJob < ApplicationJob
  queue_as :default

  retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(card_id)
    # 1. Find Card from existing card db
    Rails.logger.info("Running FetchCardInfoContingencyJob for card #{card_id}")
    card = Card.find(card_id)
    card_number = card.card_number

    set_name = card.set_name

    if set_name == "McDonald's Collection 2021"
      set_name = "McDonald's 25th Anniversary"
    end

    # card_name = PokedataParser.normalize_name(card.name)

    # 2. find the api_id for pokedata API
    response = HTTParty.get(
      "https://www.pokedata.io/v0/search",
      query: { query: card.name, asset_type: "CARD" },
      headers: { "Authorization" => "Bearer #{ENV["POKEDATA_API_KEY"]}" },
      timeout: 30
    )

    # Check if the search was successful
    return { error: "API failed" } unless response.success?
    # Parse the api response
    search_results = response.parsed_response
    # Find the matching card

    # Iterate over search results
    matching_card = search_results.find do |result|
      # Compare release date of Card(already a date) and result (converts to date)
      date_match = PokedataParser.parse_release_date(result["release_date"]) == PokedataParser.parse_release_date(card.release_date.to_s)
      # Compare card number of Card and result
      card_number_match = PokedataParser.extract_first_number(result["num"]) == PokedataParser.extract_first_number(card_number)
      # If either match a resut is returned.
      card_number_match && (card.release_date.nil? || result["release_date"].nil? || date_match)
    end

    return { error: "No matching card found" } if matching_card.nil?
    # Check matching_card

    # 3. Call Pokedata price using card.id
    pricing_response = HTTParty.get(
      "https://www.pokedata.io/v0/pricing",
      query: { id: matching_card["id"], asset_type: "CARD" },
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


      # 4. Create price history for card
    card.update!(
      pokedata_id: pricing_data["id"],
      # card_number: pricing_data["num"],
      # release_date: pricing_data["release_date"],
      set_name: pricing_data["set_name"]
    )
    # Check card.number
    card.price_histories.create!(
      pokedata_id: pricing_data["id"],
      card_name: pricing_data["name"],
      card_number: card_number,
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

    Rails.logger.info("Successfully created price history for card #{card_id}")

    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Card #{card_id} not found")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch pricing for card #{card_id}: #{e.message}")
      raise
  end
end
