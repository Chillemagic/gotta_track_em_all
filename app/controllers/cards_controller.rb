require "base64"

class CardsController < ApplicationController

  before_action :authenticate_user! # for Devise
  before_action :set_card, only: %i[show destroy]

  def index
    @cards = Card.all
  end

  def show
  end

  def search
    # Render the search page for a get request
    return render :search if request.get?
    # Check if image has been uploaded
    return redirect_to search_cards_path, alert: "Please upload an image" unless params[:search]&.dig(:image).present?

    image = params[:search][:image]

    # Identify card with OpenAi Api
    card_info = indentify_card_with_api(image)

    # Redirect if there is an error
    return redirect_to search_cards_path, alert: "Could not identify card" if card_info[:error]
    # Check the Cards db to see if the card exists
    @card = Card.find_by(name: card_info['name'], set_name: card_info['set'])
    if @card.nil?
      info = gather_card_info(card_info)
      Card.create(info)
    end
    redirect_to @card
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    if @card.save
      redirect_to @card, notice: "Card was successfully added to your collection."
    else
      render :new
    end
  end

  def destroy
    @card.destroy
    redirect_to cards_url, notice: "Card was successfully removed from your collection."
  end

  private
  gather_card_info(card)
  # Pokedata API:
  # 1. Find the pokemon id with card data
  pokedata_api_search = HTTParty.get("https://www.pokedata.io/v0/search?query=#{card['name']}&asset_type=CARD")
  search_results = pokedata_api_search.parsed_response

  matching_card = search_results.find { |result| result["set_name"] == card["set_name"] && result["num"] == card["number"] }

  # {
  #   "id": "37382",        => card.card_api_id
  #   "language": "ENGLISH",
  #   "name": "Electrode",          => card.name
  #   "num": "32",                  => card.number
  #   "release_date": "2006-02-13", => card.release_date
  #   "secret": "false",
  #   "set_code": null,
  #   "set_id": "85",             => card.set_idADD
  #   "set_name": "Legend Maker"  => card.pokemon_set
  # },


  # 2. Retrieve pricing information via pokemon id
  pricing_response = HTTParty.get("https://www.pokedata.io/v0/pricing?id=#{matching_card['id']}&asset_type=CARD")
  pricing_data = pricing_response.parsed_response



  def set_card
    @cards = Card.find(params[:id])
  end

  def indentify_card_with_api(image)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        response_format: { type: "json_object" },
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: "Identify this Pokemon card be sure to identify if the word 'staff' can be found on the card. Return only the card name, card number, card set number and if staff appears on the card in a Json that can be accessed with a key,value pair for example: {
                                    'id'=> 'base1-4',
                                    'name' => 'Charizard',
                                    'set_name' => 'Pokémon',
                                    'number' => '4',
                                    'staff' => true }" },
              { type: "image_url", image_url: { url: image_to_base64(image) } }
            ]
          }
        ]
      }
    )

    parsed_content = response.dig("choices", 0, "message", "content")
    # Parse response
    result = JSON.parse(parsed_content)
  end

  def image_to_base64(image)
    base64_image = Base64.strict_encode64(image.read)
    "data:image/jpeg;base64,#{base64_image}"
  end


  def card_params
  params.require(:card).permit(
    :card_api_id,
    :name,
    :card_number,
    :pokemon_set,
    :release_date,
    :artist,
    :rarity,
    :image,
    :image_url,
    :pokemon_types,
    :finish_type
  )
  end
end
