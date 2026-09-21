class ScrydexIdentificationJob < ApplicationJob
  class ScrydexIdentificationError < StandardError; end
  class ScrydexAuthenticationError < StandardError; end
  class ScrydexIdentificationNotFoundError < StandardError; end

  queue_as :default

  retry_on Net::OpenTimeout, Net::ReadTimeout, wait: :exponentially_longer, attempts: 3
  retry_on HTTParty::Error, ScrydexIdentificationError, wait: 5.minutes, attempts: 3
  discard_on ScrydexAuthenticationError

  after_discard do |job, error|
    search_attempt_id, user_id = job.arguments
    search_attempt = User.find_by(id: user_id)&.search_attempts&.find_by(id: search_attempt_id)
    search_attempt&.update!(status: "failed", error_message: error.message)
  end

  def perform(search_attempt_id, user_id)
    user = User.find(user_id)
    search_attempt = user.search_attempts.find(search_attempt_id)
    search_attempt.update!(status: "identifying", error_message: nil)

    unless search_attempt.image.attached?
      raise ScrydexIdentificationNotFoundError, "No image attached"
    end

    identification_response = HTTParty.post(
      "https://api.scrydex.com/vision/v1/cards/identify",
      timeout: 60,
      headers: headers,
      body: {
        image_url: search_attempt.image.url,
        games: [ "pokemon" ]
      }.to_json
    )

    ensure_success!(identification_response, "vision")

    matches = identification_response.parsed_response.dig("data", "matches")
    if matches.blank?
      raise ScrydexIdentificationNotFoundError,
        "No Scrydex vision matches found for search attempt #{search_attempt.id}"
    end

    best_match = matches.max_by { |match| match["score"].to_f }
    matched_card = best_match["card"]
    matched_card_id = matched_card&.dig("id")

    if matched_card_id.blank?
      raise ScrydexIdentificationNotFoundError,
        "The best Scrydex match did not contain a card ID"
    end

    Rails.logger.info(
      "Matched #{matched_card['name']} with score #{best_match['score']}; fetching card details"
    )

    card_response = HTTParty.get(
      "https://api.scrydex.com/pokemon/v1/cards/#{matched_card_id}",
      timeout: 60,
      headers: headers
    )

    ensure_success!(card_response, "card")

    card_info = card_response.parsed_response["data"]
    if card_info.blank?
      raise ScrydexIdentificationNotFoundError,
        "No Scrydex card data found for #{matched_card_id}"
    end

    card_number = card_info["printed_number"].presence || card_info["number"]
    set_name = card_info.dig("expansion", "name")

    search_attempt.update!(
      identified_name: card_info["name"],
      identified_number: card_number,
      identified_moves: Array(card_info["attacks"]).filter_map { |attack| attack["name"] }.join(", "),
      identified_set_name: set_name,
      identified_language: card_info["language"] || card_info.dig("expansion", "language"),
      provider: "scrydex"
    )

    card = Card.find_by(api_tcg_id: card_info["id"]) || Card.find_by(
      name: card_info["name"],
      card_number: card_number,
      set_name: set_name
    )

    if card
      search_attempt.update!(status: "matched", card_id: card.id)
      FetchCardPricingJob.perform_later(card.id)
      return
    end

    front_image = card_info["images"]&.find { |image| image["type"] == "front" } ||
      card_info["images"]&.first

    search_attempt.update!(status: "creating_card")
    card = Card.create!(
      api_tcg_id: card_info["id"],
      name: card_info["name"],
      card_number: card_number,
      artist: card_info["artist"],
      image_url: front_image&.dig("large"),
      pokemon_types: card_info["types"]&.join(", "),
      abilities: card_info["abilities"] || [],
      attacks: card_info["attacks"] || [],
      set_name: set_name,
      release_date: PokedataParser.parse_release_date(card_info.dig("expansion", "release_date")),
      language: card_info["language"] || card_info.dig("expansion", "language"),
      holo_type: search_attempt.holo_type,
      status: "processing",
      api_tcg_status: "pending"
    )

    search_attempt.update!(card_id: card.id)

    unless card.complete_card_info?
      missing_fields = card.missing_fields.join(", ")
      card.update!(status: "incomplete", api_tcg_status: "incomplete")
      search_attempt.update!(
        status: "failed",
        error_message: "Card data was incomplete: #{missing_fields}"
      )
      return
    end

    card.update!(status: "complete", api_tcg_status: "complete")
    search_attempt.update!(status: "matched")
    FetchCardPricingJob.perform_later(card.id)
  rescue ScrydexIdentificationNotFoundError => e
    search_attempt&.update!(status: "failed", error_message: e.message)
    Rails.logger.warn(e.message)
  end

  private

  def headers
    {
      "X-Api-Key" => Rails.application.credentials.dig(:scrydex, :api_key),
      "X-Team-ID" => "gtea"
    }
  end

  def ensure_success!(response, request_name)
    return if response.success?

    message = "Scrydex #{request_name} request failed with HTTP #{response.code}"
    Rails.logger.error("#{message}; response: #{response.body.to_s.truncate(1_000)}")

    error_class = response.code.to_i == 401 ? ScrydexAuthenticationError : ScrydexIdentificationError
    raise error_class, message
  end
end
