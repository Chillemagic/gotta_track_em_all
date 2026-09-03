require "base64"

class IdentifyCardJob < ApplicationJob
  queue_as :default

  def perform(search_attempt_id)
    search_attempt = SearchAttempt.find(search_attempt_id)
    search_attempt.update!(status: "identifying", error_message: nil)

    Rails.logger.info("Starting IdentifyCardJob for search attempt #{search_attempt_id}")

    unless search_attempt.image.attached?
      search_attempt.update!(status: "failed", error_message: "No image provided")
      Rails.logger.error("Error: #{search_attempt.error_message}")
      return
    end

    formatted_image = image_data_url(search_attempt.image)
    card_info = identify_card_with_api(formatted_image)

    if card_info["error"].present?
      search_attempt.update!(
        status: "failed",
        error_message: card_info["error"]
      )
      Rails.logger.error("Error: #{search_attempt.error_message}")

      return
    end

    search_attempt.update!(
      identified_name: card_info["name"],
      identified_number: card_info["number"],
      identified_set_name: card_info["set_name"],
      identified_rarity: card_info["rarity"],
      identified_moves: card_info["card_effect/attack"],
      identified_language: card_info["language"],
      identified_staff: card_info["staff"]
    )

    Rails.logger.info(
      "Card identified name: #{card_info['name']}, number: #{card_info['number']}"
    )

    match = Card.find_by(
      name: card_info["name"],
      card_number: card_info["number"],
      holo_type: search_attempt.holo_type
    )

    if match.present?
      Rails.logger.info("Existing card found, card name:#{match.name},match id: #{match.id}")
      search_attempt.update!(card: match, status: "matched")
      UpdatePriceHistoryJob.perform_later(match.id)
    else
      card = Card.create!(
        name: card_info["name"],
        set_name: card_info["set_name"],
        card_number: card_info["number"],
        rarity: card_info["rarity"],
        holo_type: search_attempt.holo_type,
        status: "complete"
      )

      search_attempt.update!(card: card, status: "creating_card")
      Rails.logger.info("Created card with ID: #{card.id}, name: #{card.name}, set: #{card.set_name}, card_number: #{card.card_number}, rarity: #{card.rarity}")

      FetchCardInfoJob.perform_later(card.id, search_attempt.user_id)
    end
  rescue StandardError => e
    search_attempt&.update(status: "failed", error_message: e.message)
    Rails.logger.error(
      "IdentifyCardJob failed for search attempt #{search_attempt_id}: #{e.message}"
    )
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
                      from the sets provided. If a gold star is found in the card name near the top return the rarity as 'Rare Holo Star'
                      otherwise leave the ratiy empty. Identify the card number and make sure to ommit any leading zero for example don't 
                      do 086/096 instead use 86/96. Pay attention to any name suffix for example Charizard-GX and be sure to include 
                      it in the name Return only the card name, card number, card set, first card effect/attack title, language, rarity(only return if gold star is present)
                      and if staff appears on the card in a Json that can be accessed with a key,value pair. Here is the JSON example: {
                      'id'=> 'base1-4',
                      'name' => 'Charizard',
                      'set_name' => 'Pokémon',
                      'rarity' => 'only return rarity if gold star is found!',
                      'number' => '4/102',
                      'card_effect/attack' => 'Solar Wind'
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
    return { error: "No response from OpenAI" } if parsed_content.nil?

    JSON.parse(parsed_content)
  rescue JSON::ParserError => e
    { error: "Invalid JSON response: #{e.message}" }
  rescue StandardError => e
    { error: "OpenAI API error: #{e.message}" }
  end

  private
  # Might need to uncomment later
  def image_data_url(image)
    encoded_image = Base64.strict_encode64(image.download)
    content_type = image.blob.content_type.presence || "image/jpeg"

    "data:#{content_type};base64,#{encoded_image}"
  end
end
