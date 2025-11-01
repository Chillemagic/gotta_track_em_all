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
        query: { name: card.name }
      )

    # Check if request was successful
    unless response.success?
      Rails.logger.error("Pokemon TCG API failed: #{response.code} - #{response.message}")
      FetchCardInfoContingencyJob.perform_later(card.id)
      return
    end

    # Parse the api call
    cards_response = response.parsed_response
    cards = cards_response["data"]
    # Use existing api id if one has been created
    cards = cards.select { |c| c["id"] == card.api_tcg_id } if card.api_tcg_id.present?
    Rails.logger.info("API returned #{cards.length} cards")
    # Match card name and set
    # Iterate through cards

    card_info = cards.find do |c|
      # Strip and downcase card and c to compare
      name_match = PokedataParser.normalize_name(c["name"]) == PokedataParser.normalize_name(card.name)
      #-------------------------------------------------------------------------------------------------------------------------------------
      number_match = PokedataParser.extract_first_number(c["code"]||c["number"].to_s) == PokedataParser.extract_first_number(card.card_number.to_s)
      # Use card number as comparison

      name_match && number_match
    end

    if card_info.nil?
      Rails.logger.error("Checking card suffixes for: #{card.name}")

      suffixes = [
        "-GX", "-EX", "-V", "-VMAX", "-VSTAR", "-VUNION", "-BREAK",
        "-LEGEND", "-LV.X", "-TAG TEAM", "-MEGA", "-C", "-PRISM STAR"
      ]

      suffixes.each do |suf|
        search_name = "#{card.name}#{suf}"

        matching_card = cards.find do |c|
          PokedataParser.normalize_name(c["name"]) == PokedataParser.normalize_name(search_name) &&
          PokedataParser.extract_first_number(c["code"]||c["number"].to_s) == PokedataParser.extract_first_number(card.card_number.to_s)
        end

        if matching_card
          card_info = matching_card
          Rails.logger.info("Found card using suffix: #{suf}")
          break
        end
      end
    end

    if card_info.nil?
      Rails.logger.error("No matching card found for #{card.name} (#{card.card_number}) in set #{card.set_name}")
      FetchCardInfoContingencyJob.perform_later(card.id)
      return
    end

    # Save to database
    card.update(
      api_tcg_id: card_info.dig("id"),
      artist: card_info.dig("artist"),
      rarity: card_info.dig("rarity"),
      image_url: card_info.dig("images", "large"),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info.dig("abilities"),
      attacks: card_info.dig("attacks"),
      set_name: card_info.dig("set", "name"),
      release_date: PokedataParser.parse_release_date(card_info.dig("set", "releaseDate"))
    )
    # refresh card for most accurate check
    card.reload

    unless card.complete_card_info?
      Rails.logger.warn("Card ##{card.id} missing: #{card.missing_fields.join(', ')}")
      FetchCardInfoContingencyJob.perform_later(card_id)
      return
    end

    Rails.logger.info("Successfully updated card #{card.id} with Pokemon TCG data")
    card.update!(api_tcg_status: "complete")

  rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Card #{card_id} not found")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch card info for #{card_id}: #{e.message}")
      raise
  end
end
