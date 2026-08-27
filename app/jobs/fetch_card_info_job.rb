class FetchCardInfoJob < ApplicationJob
  queue_as :default

  # retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  # retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(card_id, user_id)
    @user_id = user_id
    Rails.logger.info("Running FetchCardInfoJob for card #{card_id}")
    # Find created card to add to
    user = User.find(@user_id)
    card = Card.find(card_id)
    card.update!(api_tcg_status: "pending")
    # Broadcast turbo stream
    # broadcast(card)

    # Fetch with retry logic and long timeout
    response = HTTParty.get(
      # "https://api.pokemontcg.io/v2/cards"
      "https://api.scrydex.com/pokemon/v1/cards",
      timeout: 60,
      headers: { "X-Api-Key" => ENV["SCRYDEX_API_KEY"], "X-Team-ID" => "gtea" },
      query: { q: card.name }
      )

    # Check if request was successful
    unless response.success?
      Rails.logger.error("Pokemon TCG API failed: #{response.code} - #{response.message}")
      # Update card status and broadcast turbo stream
      card.update!(api_tcg_status: "incomplete")
      # broadcast(card)
      return
    end

    # Parse the api call
    cards_response = response.parsed_response
    cards = cards_response["data"]
    # Use existing api id if one has been created
    cards = cards.select { |c| c["id"] == card.api_tcg_id } if card.api_tcg_id.present?
    Rails.logger.info("API returned #{cards.length} cards")
    # Match card name and set
    # Queue generating Card Objects from rejected cards to save Api calls 
    
    card_info = cards.find do |c|
      # Strip and downcase card and c to compare
      name_match = PokedataParser.normalize_name(c["name"]) == PokedataParser.normalize_name(card.name)
      number_match = PokedataParser.extract_first_number(c["printed_number"].to_s) == PokedataParser.extract_first_number(card.card_number.to_s)
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
          PokedataParser.extract_first_number(c["printed_number"].to_s) == PokedataParser.extract_first_number(card.card_number.to_s)
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
      # Update card status and broadcast turbo stream
      card.update!(api_tcg_status: "incomplete")
      # broadcast(card)
      return
    end
    rejected_cards = cards.reject do |candidate|
      candidate["id"] == card_info["id"]
    end

    AddRejectedCardsFromApiJob.perform_later(rejected_cards) if rejected_cards.any?

    # Scrydex returns images as an array (one entry per card side).
    front_image = card_info["images"]&.find { |image| image["type"] == "front" } || card_info["images"]&.first

    # Save to database
    card.update!(
      api_tcg_id: card_info.dig("id"),
      artist: card_info.dig("artist"),
      rarity: card_info.dig("rarity"),
      image_url: front_image&.dig("large"),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info.dig("abilities"),
      attacks: card_info.dig("attacks"),
      set_name: card_info.dig("expansion", "name"),
      release_date: PokedataParser.parse_release_date(card_info.dig("expansion", "release_date"))
    )
    # refresh card for most accurate check
    card.reload

    unless card.complete_card_info?
      Rails.logger.warn("Card ##{card_id} missing: #{card.missing_fields.join(', ')}")
      # Update card status and broadcast turbo stream
      card.update!(api_tcg_status: "incomplete")
      # broadcast(card)
      return
    end

    Rails.logger.info("Successfully updated card #{card_id} with Pokemon TCG data")
    # Update card status and broadcast turbo stream
    card.update!(api_tcg_status: "complete")
    FetchCardPricingJob.perform_now(card_id)
    # broadcast(card)

  rescue ActiveRecord::RecordNotFound
      Rails.logger.error("Card #{card_id} not found")
    rescue StandardError => e
      Rails.logger.error("Failed to fetch card info for #{card_id}: #{e.message}")
      raise
  end


  def extract_first_number(card_number)
    return "" if card_number.nil? || card_number.empty?
    # Filter out leading zeros and second number or convert nil to ""
    num = card_number.to_s[/^[A-Za-z0-9]+/] || ""
    # Subs in first number or nil for ''
    first_number = num.sub(/^0+/, "") # remove leading zeros if numeric
    # Result is K097/K099 => K97 or nil => "" for error handling
    first_number
  end

  private

  def broadcast(card)
    Turbo::StreamsChannel.broadcast_replace_to(
      "card_#{card_id}",
      target: "card-details",
      partial: "cards/card_info",
      locals: { card: card }
    )
  end
end
