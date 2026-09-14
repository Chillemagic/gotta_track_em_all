require "base64"

class IdentifyCardJob < ApplicationJob
  class NoExactMatchError < StandardError; end

  queue_as :default

  def perform(search_attempt_id, current_user_id)
    user = User.find(current_user_id)
    search_attempt = user.search_attempts.find(search_attempt_id)


    Rails.logger.info("Starting IdentifyCardJob")
    search_attempt.update!(status: "identifying", error_message: nil)
    # Render the search page for a get request
    # !! return render :search if request.get? || request.head?
    # Check if image has been uploaded
    unless search_attempt.image.attached?
      search_attempt.update!(status: "failed",
                   error_message: "No image provided"
      )
      Rails.logger.error("Error: #{search_attempt.error_message}")
      return
      # Handle redirect in view return redirect_to search_cards_path, alert: "Please upload an image"
    end

    formatted_image = image_data_url(search_attempt.image)
    # Identify search_attempt with OpenAi Api
    card_info = identify_card_with_api(formatted_image)

    if card_info["error"].present?
      search_attempt.update!(
        status: "failed",
        error_message: card_info["error"]
      )
      Rails.logger.error("Error: #{search_attempt.error_message}")

      return
    end

    Rails.logger.info(
      "Card identified name: #{card_info['name']}, number: #{card_info['number']}"
    )

    # Check the Cards db to see if the card exists
    match = find_match(search_attempt, card_info)

    # Update price and direct to matching card show page
    if match.present?
      Rails.logger.info("Existing card found, card name:#{match.name},match id: #{match.id}")
      search_attempt.update!(
        status: "matched",
        card: match,
        error_message: nil,
        identified_name: card_info["name"],
        identified_number: card_info["number"],
        identified_set_name: card_info["set_name"],
        identified_moves: card_info["first_card_ability_or_attack"],
        identified_language: card_info["language"],
        identified_staff: card_info["staff"]
      )
      UpdatePriceHistoryJob.perform_later(match.id)
      #  # Handle redirect in view redirect_to card_path(match)
    else
      # Update card and fetch more info
      search_attempt.update!(
      identified_name: card_info["name"],
      identified_set_name: card_info["set_name"],
      identified_number: card_info["number"],
      identified_moves: card_info["first_card_ability_or_attack"],
      status: "creating_card"
      )

      Rails.logger.info("Fetching card info for search attempt #{search_attempt.id}: #{search_attempt.identified_name}")

      FetchCardInfoJob.perform_later(search_attempt.id, user.id)
    end

  rescue StandardError => e
    search_attempt&.update!(status: "failed", error_message: e.message)
    Rails.logger.error("IdentifyCardJob failed for search attempt #{search_attempt_id}: #{e.message}")
    raise
  end

  def identify_card_with_api(image)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        response_format: { type: "json_object" },
        messages: [
          {
            role: "user",
            content: [
              { type: "text",
                text: "Identify this Pokemon card be sure to identify if the word 'staff' can be found on the card and please select
                      from the sets provided. Identify the card number and make sure to ommit any leading zero for example don't
                      do 086/096 instead use 86/96. Pay attention to any name suffix for example Charizard-GX and be sure to include
                      it in the name. If a card effect or attack is present be sure to include only the title of the first effect or
                      attack that appears. Some attacks and effects have descripions that I don't want returned. I.e: Card has
                      'Rest: Recover 4hp at the cost of 1 energy. This card is immobilized for one turn after resting' would only yield
                      'Rest'. Return only the card name, card number, card set, first card effect/attack title, language,
                      and if staff appears on the card in a Json that can be accessed with a key,value pair. Here is the JSON example: {
                      'id'=> 'base1-4',
                      'name' => 'Charizard',
                      'set_name' => 'Pokémon',
                      'number' => '4/102',
                      'first_card_ability_or_attack' => 'Solar Wind'
                      'language' => 'English',
                      'staff' => true }"
                },
                { type: "image_url", image_url: { url: image }
              }
            ]
          }
        ]
      }
    )

    parsed_content = response.dig("choices", 0, "message", "content")
    # Parse response
    return { "error" => "No response from OpenAI" } if parsed_content.nil?

    JSON.parse(parsed_content)
  rescue JSON::ParserError => e
    { "error" => "Invalid JSON response: #{e.message}" }

  rescue StandardError => e
    { "error" => "OpenAI API error: #{e.message}" }
  end

  private
  # Might need to uncomment later
  def find_match(search_attempt, card_info)
    results = Card.where(
      name: card_info["name"],
      card_number: card_info["number"]
    )

    return nil if results.empty?

    return results.first if results.one?

    move_name = card_info["first_card_ability_or_attack"].to_s.strip

    if move_name.blank?
      raise NoExactMatchError,
            "Multiple cards were found, but no ability or attack was identified"
    end

    match = results.find do |result|
      ability_name = result.abilities&.first&.dig("name")
      attack_name = result.attacks&.first&.dig("name")

      names_match?(ability_name, move_name) ||
        names_match?(attack_name, move_name)
    end

    return match if match

  raise NoExactMatchError,
          "No candidate matched the identified ability or attack: #{move_name}"
  end

  def names_match?(candidate, identified)
    candidate.to_s.strip.casecmp?(identified.to_s.strip)
  end

  def image_data_url(image)
    encoded_image = Base64.strict_encode64(image.download)
    content_type = image.blob.content_type.presence || "image/jpeg"

    "data:#{content_type};base64,#{encoded_image}"
  end
end
