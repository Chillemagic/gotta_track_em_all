require "base64"
class CardsController < ApplicationController
  layout "background_pattern_dark"

  before_action :authenticate_user! # for Devise
  before_action :set_card, only: %i[show destroy]


  def index
    @cards = Card.all
  end

  def show
    @collection = Collection.new
  end

  def search
    # Render the search page for a get request
    return render :search if request.get? ||request.head?
    # Check if image has been uploaded
    unless params[:search]&.dig(:image).present?
      return redirect_to search_cards_path, alert: "Please upload an image"
    end
    image = params[:search][:image]

    # Identify card with OpenAi Api
    card_info = identify_card_with_api(image)

    # Redirect if there is an error
    if card_info["error"]
      return redirect_to search_cards_path, alert: "Could not identify card"
    end

    # Check the Cards db to see if the card exists
    @card = Card.find_by(name: card_info["name"], card_number: card_info["number"])

    if @card.present?
      UpdatePriceHistoryJob.perform_later(@card.id)
    else
      # Create new card with just the name and
      @card = Card.create!(
        name: card_info["name"],
        set_name: card_info["set_name"],
        card_number: card_info["number"],
        rarity: card_info["rarity"]
      )
      Rails.logger.info("Created card with ID: #{@card.id}, name: #{@card.name}, set: #{@card.set_name}, card_number: #{@card.card_number}, rarity: #{@card.rarity}")

      FetchCardInfoJob.perform_later(@card.id, current_user.id)
    end

    redirect_to @card

  rescue ActiveRecord::RecordInvalid => e
    redirect_to search_cards_path, alert: "Failed to save card: #{e.message}"
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

  def set_card
    @card = Card.find(params[:id])
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
                text: "Identify this Pokemon card be sure to identify if the word 'staff' can be found on the card and please select from the sets provided. If a gold star is found in the card name near the top return the rarity as 'Rare Holo Star' otherwise leave the ratiy empty. Identify the card number and make sure to ommit any leading zero for example don't do 086/096 instead use 86/96. Pay attention to any name suffix for example Charizard-GX and be sure to include it in the name Return only the card name, card number, card set, language, rarity(only return if gold star is present) and if staff appears on the card in a Json that can be accessed with a key,value pair. Here is the JSON example followed by the set names example: {
                      'id'=> 'base1-4',
                      'name' => 'Charizard',
                      'set_name' => 'Pokémon',
                      'rarity' => 'only return rarity if gold star is found!',
                      'number' => '4/102',
                      'language' => 'English',
                      'staff' => true }
                      Here are the set names:
                      ['Base', 'Jungle', 'Wizards Black Star Promos', 'Fossil', 'Base Set 2', 'Team Rocket', 'Gym Heroes', 'Gym Challenge',
                      'Neo Genesis', 'Neo Discovery', 'Southern Islands', 'Neo Revelation', 'Neo Destiny', 'Legendary Collection', 'Expedition Base Set',
                      'Aquapolis', 'Skyridge', 'Ruby & Sapphire', 'Sandstorm', 'Dragon', 'Nintendo Black Star Promos', 'Team Magma vs Team Aqua',
                      'Hidden Legends', 'FireRed & LeafGreen', 'POP Series 1', 'Team Rocket Returns', 'Deoxys', 'Emerald', 'Unseen Forces', 'POP Series 2',
                      'Delta Species', 'Legend Maker', 'POP Series 3', 'Holon Phantoms', 'Crystal Guardians', 'POP Series 4', 'Dragon Frontiers', 'POP Series 5',
                      'Power Keepers', 'Diamond & Pearl', 'DP Black Star Promos', 'Mysterious Treasures', 'POP Series 6', 'Secret Wonders', 'Great Encounters',
                      'POP Series 7', 'Majestic Dawn', 'Legends Awakened', 'POP Series 8', 'Stormfront', 'Platinum', 'POP Series 9', 'Rising Rivals', 'Supreme Victors',
                      'Arceus', 'Pokémon Rumble', 'HeartGold & SoulSilver', 'HGSS Black Star Promos', 'HS—Unleashed', 'HS—Undaunted', 'HS—Triumphant', 'Call of Legends',
                      'BW Black Star Promos', 'Black & White', 'McDonald's Collection 2011', 'Emerging Powers', 'Noble Victories', 'Next Destinies', 'Dark Explorers',
                      'McDonald's Collection 2012', 'Dragons Exalted', 'Dragon Vault', 'Boundaries Crossed', 'Plasma Storm', 'Plasma Freeze', 'Plasma Blast',
                      'XY Black Star Promos', 'Legendary Treasures', 'Kalos Starter Set', 'XY', 'Flashfire', 'Furious Fists', 'Phantom Forces', 'Primal Clash',
                      'Double Crisis', 'Roaring Skies', 'Ancient Origins', 'BREAKthrough', 'BREAKpoint', 'Generations', 'Fates Collide', 'Steam Siege', 'McDonald's Collection 2016',
                      'Evolutions', 'Sun & Moon', 'SM Black Star Promos', 'Guardians Rising', 'Burning Shadows', 'Shining Legends', 'Crimson Invasion', 'Ultra Prism', 'Forbidden Light',
                      'Celestial Storm', 'Dragon Majesty', 'Lost Thunder', 'Team Up', 'Detective Pikachu', 'Unbroken Bonds', 'Unified Minds', 'Hidden Fates', 'Hidden Fates Shiny Vault',
                      'McDonald's Collection 2019', 'Cosmic Eclipse', 'SWSH Black Star Promos', 'Sword & Shield', 'Rebel Clash', 'Darkness Ablaze', 'Champion's Path', 'Vivid Voltage',
                      'Shining Fates', 'Shining Fates Shiny Vault', 'Battle Styles', 'Chilling Reign', 'Evolving Skies', 'Celebrations', 'Celebrations: Classic Collection',
                      'McDonald's Collection 2014', 'McDonald's Collection 2015', 'McDonald's Collection 2018', 'McDonald's Collection 2017', 'McDonald's Collection 2021', 'Best of Game',
                      'Fusion Strike', 'Pokémon Futsal Collection', 'EX Trainer Kit Latias', 'EX Trainer Kit Latios', 'EX Trainer Kit 2 Plusle', 'EX Trainer Kit 2 Minun', 'Brilliant Stars',
                      'Brilliant Stars Trainer Gallery', 'Astral Radiance', 'Astral Radiance Trainer Gallery', 'Pokémon GO', 'Lost Origin', 'Lost Origin Trainer Gallery', 'Silver Tempest',
                      'Silver Tempest Trainer Gallery', 'McDonald's Collection 2022', 'Crown Zenith', 'Crown Zenith Galarian Gallery', 'Scarlet & Violet', 'Scarlet & Violet Black Star Promos',
                      'Paldea Evolved', 'Scarlet & Violet Energies', 'Obsidian Flames', '151', 'Paradox Rift', 'Paldean Fates', 'Temporal Forces', 'Twilight Masquerade', 'Shrouded Fable', 'Stellar Crown',
                      'Surging Sparks', 'Prismatic Evolutions', 'Journey Together', 'Destined Rivals', 'Black Bolt', 'White Flare', 'Mega Evolution']" },

              { type: "image_url", image_url: { url: image_to_base64(image) } }
            ]
          }
        ]
      }
    )

    parsed_content = response.dig("choices", 0, "message", "content")
    # Parse response
    return { error: "No response from OpenAI" } if parsed_content.nil?

    identified_card = JSON.parse(parsed_content)

    identified_card
  rescue JSON::ParserError => e
    { error: "Invalid JSON response: #{e.message}" }
  rescue StandardError => e
    { error: "OpenAI API error: #{e.message}" }
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
