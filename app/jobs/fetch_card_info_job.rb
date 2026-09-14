class FetchCardInfoJob < ApplicationJob
  queue_as :default

  # retry_on Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  # retry_on HTTParty::Error, wait: 5.minutes, attempts: 3

  def perform(search_attempt_id, user_id)
    @user_id = user_id
    # Find created card to add to
    user = User.find(@user_id)
    search_attempt = user.search_attempts.find(search_attempt_id)

    Rails.logger.info("Running FetchCardInfoJob for card #{search_attempt.identified_name}")
    cards = []
    card_info = nil
    page = 1
    page_size = 100

    loop do
      response = HTTParty.get(
        "https://api.scrydex.com/pokemon/v1/cards",
        timeout: 60,
        headers: { "X-Api-Key" => ENV["SCRYDEX_API_KEY"], "X-Team-ID" => "gtea" },
        query: { q: search_attempt.identified_name, page: page, page_size: page_size }
      )

      unless response.success?
        Rails.logger.error("Scrydex API failed: #{response.code} - #{response.message}")
        search_attempt.update!(status: "failed")
        return
      end

      payload = response.parsed_response
      page_cards = Array(payload["data"])
      Rails.logger.info("API returned #{page_cards.length} cards on page #{page}")
      # Stop if an upstream pagination error repeats a page.
      new_cards = page_cards.reject { |candidate| cards.any? { |seen| seen["id"] == candidate["id"] } }
      break if new_cards.empty?

      cards.concat(new_cards)
      card_info = new_cards.find { |candidate| matches_identification?(candidate, search_attempt) }
      break if card_info

      total_count = payload["totalCount"] || payload["total_count"]
      returned_page_size = (payload["pageSize"] || payload["page_size"] || page_size).to_i
      break if returned_page_size <= 0
      break if total_count && page * returned_page_size >= total_count.to_i
      break if !total_count && page_cards.length < returned_page_size

      page += 1
    end

    if card_info.nil?
      Rails.logger.error("No matching card found for #{search_attempt.identified_name} (#{search_attempt.identified_number}) in set #{search_attempt.identified_set_name}")
      # Update card status and broadcast turbo stream
      search_attempt.update!(status: "failed")
      # broadcast(card)
      return
    end
    rejected_cards = cards.reject do |candidate|
      candidate["id"] == card_info["id"]
    end

    AddRejectedCardsFromApiJob.perform_later(rejected_cards) if rejected_cards.any?

    # Scrydex returns images as an array (one entry per card side).
    front_image = card_info["images"]&.find { |image| image["type"] == "front" } || card_info["images"]&.first

    existing_card = Card.find_by(api_tcg_id: card_info["id"])
    if existing_card
      search_attempt.update!(
        card: existing_card,
        status: "matched",
        error_message: nil
      )
      FetchCardPricingJob.perform_later(existing_card.id)
      return
    end

    # Save to database
    search_attempt.update!(status: "creating_card")
    card = Card.create!(
      api_tcg_id: card_info["id"],
      name: card_info["name"],
      card_number: card_info["printed_number"].presence || card_info["number"],
      artist: card_info["artist"],
      # rarity: card_info["rarity"],
      image_url: front_image&.dig("large"),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info["abilities"] || [],
      attacks: card_info["attacks"] || [],
      set_name: card_info.dig("expansion", "name"),
      release_date: PokedataParser.parse_release_date(card_info.dig("expansion", "release_date")),
      language: card_info["language"] || card_info.dig("expansion", "language"),
      holo_type: search_attempt.holo_type,
      status: "processing",
      api_tcg_status: "pending"
    )
    # refresh card for most accurate check
    search_attempt.update!(card_id: card.id)
    card.reload

    unless card.complete_card_info?
      Rails.logger.warn("Card ##{card.id} missing: #{card.missing_fields.join(', ')}")
      # Update card status and broadcast turbo stream
      card.update!(status: "incomplete", api_tcg_status: "incomplete")
      search_attempt.update!(
        status: "failed",
        error_message: "Card data was incomplete: #{card.missing_fields.join(', ')}"
      )
      return
    end

    Rails.logger.info("Successfully updated card #{card.id} with Scrydex data")
    # Update card status and broadcast turbo stream
    card.update!(status: "complete",
                 api_tcg_status: "complete"
    )
    search_attempt.update!(status: "matched")
    FetchCardPricingJob.perform_now(card.id)
    # broadcast(card)

  rescue StandardError => e
    search_attempt&.update!(status: "failed", error_message: e.message)
    Rails.logger.error("Failed to fetch card info for search attempt #{search_attempt_id}: #{e.message}")
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

  def matches_identification?(candidate, search_attempt)
    suffixes = [ "", "-GX", "-EX", "-V", "-VMAX", "-VSTAR", "-VUNION",
                "-BREAK", "-LEGEND", "-LV.X", "-TAG TEAM", "-MEGA", "-C", "-PRISM STAR" ]
    name_match = suffixes.any? do |suffix|
      PokedataParser.normalize_name(candidate["name"]) ==
        PokedataParser.normalize_name("#{search_attempt.identified_name}#{suffix}")
    end
    candidate_number = candidate["printed_number"].presence || candidate["number"]
    number_match = search_attempt.identified_number.present? &&
      PokedataParser.extract_first_number(candidate_number.to_s) ==
        PokedataParser.extract_first_number(search_attempt.identified_number.to_s)
    return false unless name_match && number_match

    if search_attempt.identified_moves.present?
      first_move = Array(candidate["abilities"]).first || Array(candidate["attacks"]).first
      identified_move = normalize_move(search_attempt.identified_moves)
      identified_move.present? && identified_move == normalize_move(first_move&.dig("name"))
    else
      search_attempt.identified_set_name.present? &&
        PokedataParser.normalize_name(candidate.dig("expansion", "name")) ==
          PokedataParser.normalize_name(search_attempt.identified_set_name)
    end
  end

  def normalize_move(name)
    name.to_s.downcase.gsub(/[^a-z0-9]/, "")
  end

  # def broadcast(card)
  #   Turbo::StreamsChannel.broadcast_replace_to(
  #     "card_#{card_id}",
  #     target: "card-details",
  #     partial: "cards/card_info",
  #     locals: { card: card }
  #   )
  # end
end
