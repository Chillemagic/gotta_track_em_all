require "base64"

class IdentifyCardJob < ApplicationJob
  queue_as :default

  def perform(search_attempt, current_user)
    search_attempt = Card.find(search_attempt)


    Rails.logger.info("Starting IdentifyCardJob")
    # Render the search page for a get request
    # !! return render :search if request.get? || request.head?
    # Check if image has been uploaded
    unless search_attempt.image.attached?
      search_attempt.update!(status: "incomplete",
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
        status: "incomplete",
        error_message: card_info["error"]
      )
      Rails.logger.error("Error: #{search_attempt.error_message}")

      return
    end

    Rails.logger.info(
      "Card identified name: #{card_info['name']}, number: #{card_info['number']}"
    )

    # Check the Cards db to see if the card exists
    match = Card.find_by(name: card_info["name"], card_number: card_info["number"], holo_type: search_attempt.holo_type)

    # Update price and direct to matching card show page
    if match.present?
      Rails.logger.info("Existing card found, card name:#{match.name},match id: #{match.id}")
      search_attempt.update!(status: "duplicate", error_message: match.id.to_s)
      UpdatePriceHistoryJob.perform_later(match.id)
      #  # Handle redirect in view redirect_to card_path(match)
    else
      # Update card and fetch more info
      search_attempt.update!(
      name: card_info["name"],
      set_name: card_info["set_name"],
      card_number: card_info["number"],
      rarity: card_info["rarity"],
      status: "complete"
      )
      Rails.logger.info("Created card with ID: #{search_attempt.id}, name: #{search_attempt.name}, set: #{search_attempt.set_name}, card_number: #{search_attempt.card_number}, rarity: #{search_attempt.rarity}")

      FetchCardInfoJob.perform_later(search_attempt.id, current_user)
    end

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error(
      "IdentifyCardJob failed for card #{search_attempt}:
      #{e.message}"
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
