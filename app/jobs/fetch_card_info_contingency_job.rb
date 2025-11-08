class FetchCardInfoContingencyJob < ApplicationJob
  queue_as :default

  retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  class APIError < StandardError; end
  class CardNotFoundError < StandardError; end

  def perform(card_id)
    card = Card.find(card_id)
    # broadcast(card)
    # Step 1: Search for card by name and number
    tcgdex_id = fetch_tcgdex_id(card)
    raise CardNotFoundError, "No matching card found in TCGdex" unless tcgdex_id

    card.update!(tcgdex_id: tcgdex_id)

    # Step 2: Fetch detailed card information
    card_info = fetch_card_details(tcgdex_id)
    update_card_info(card, card_info)
    # broadcast(card)

    # Step 3: Fetch set information for release date
    set_info = fetch_set_info(card.tcgdex_id)
    update_release_date(card, set_info)
    # broadcast(card)

    Rails.logger.info("Successfully fetched card info for Card ##{card_id}")
  rescue CardNotFoundError => e
    Rails.logger.warn("Card ##{card_id}: #{e.message}")
    card.update(fetch_failed: true) # Optional: track failed fetched
    broadcast(card)
  rescue APIError => e
    Rails.logger.error("Card ##{card_id}: #{e.message}")
    raise # Let retry mechanism handle it
  end

  private

  def broadcast(card)
    Turbo::StreamsChannel.broadcast_replace_to(
      "card_#{card.id}",
      target: "card-details",
      partial: "cards/card_info",
      locals: { card: card }
    )
  end

  def fetch_tcgdex_id(card)
    response = HTTParty.get(
      "https://api.tcgdex.net/v2/en/cards",
      query: {
        name: card.name,
        localId: PokedataParser.extract_first_number(card.card_number)
      },
      timeout: 30
    )

    raise APIError, "Card search API failed: #{response.code}" unless response.success?

    results = response.parsed_response
    return nil if results.blank? || !results.is_a?(Array)

    results.first&.dig("id")
  end

  def fetch_card_details(tcgdex_id)
    response = HTTParty.get(
      "https://api.tcgdex.net/v2/en/cards/#{tcgdex_id}",
      timeout: 30
    )

    raise APIError, "Card details API failed: #{response.code}" unless response.success?

    response.parsed_response
  end

  def fetch_set_info(tcgdex_id)
    set_id = PokedataParser.extract_first_number(tcgdex_id)
    response = HTTParty.get(
      "https://api.tcgdex.net/v2/en/sets/#{set_id}",
      timeout: 30
    )

    raise APIError, "Set info API failed: #{response.code}" unless response.success?

    response.parsed_response
  end

  def update_card_info(card, card_info)
    card.update!(
      artist: card_info["illustrator"],
      rarity: card_info["rarity"],
      image_url: build_image_url(card_info["image"]),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info["abilities"],
      attacks: card_info["attacks"],
      set_name: card_info.dig("set", "name")
    )
  end

  def update_release_date(card, set_info)
    release_date = PokedataParser.parse_release_date(set_info["releaseDate"])
    card.update!(release_date: release_date, tcg_dex_status: "complete") if release_date.present?
  end

  def build_image_url(base_url)
    return nil unless base_url.present?
    "#{base_url}/high.webp"
  end

end
