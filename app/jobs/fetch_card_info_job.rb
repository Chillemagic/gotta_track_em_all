class FetchCardInfoJob < ApplicationJob
  queue_as :default

  # retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  # retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(card_id)
    puts "Running FetchCardInfoJob"
    # Find created card to add to
    card = Card.find(card_id)

    # Fetch with retry logic and long timeout
    response = HTTParty.get(
      # "https://api.pokemontcg.io/v2/cards"
      "https://apitcg.com/api/pokemon/cards",
      timeout: 60,
      headers: { "x-api-key" => ENV["API_TCG_KEY"] },
        # query: { q: 'name:"' + card.name + '" set.name:"' + card.set_name + '"' }
        query: { name: card.name, rarity: card.rarity }
      )

    # Check if request was successful
    unless response.success?
      Rails.logger.error("Pokemon TCG API failed: #{response.code} - #{response.message}")
      return
    end

    # Parse the api call
    cards_response = response.parsed_response
    cards = cards_response["data"]

    Rails.logger.info("API returned #{cards.length} cards")
    # Match card name and set
    # Iterate through cards
    card_info = cards.find do |c|
      # Strip and downcase card and c to compare
      name_match = normalize_name(c["name"]) == normalize_name(card.name)

      if card.rarity.present?
       match = name_match && normalize_name(c["rarity"]) == normalize_name(card.rarity)
      else
       match = name_match && normalize_name(c["set"]["name"]).include?(normalize_name(card.set_name))
      end
      match
    end

    debugger

    if card_info.nil?
      Rails.logger.error("No card found in API for: #{card.name} (#{card.set_name})")
      Rails.logger.error("API returned #{cards&.length || 0} results")
      return
    end

    # Save to database
    card.update!(
      pokedata_id: card_info.dig("id"),
      artist: card_info.dig("artist"),
      rarity: card_info.dig("rarity"),
      image_url: card_info.dig("images", "large"),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info.dig("abilities")&.to_json,
      attacks: card_info.dig("attacks")&.to_json,
      set_name: card_info.dig("set", "name")
    )

    debugger
    Rails.logger.info("Successfully updated card #{card.id} with Pokemon TCG data")

    rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Card #{card_id} not found")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch card info for #{card_id}: #{e.message}")
      raise
  end

  def normalize_name(name)
    name.to_s.downcase.gsub(/[^a-z0-9-]/, "")
  end
end
