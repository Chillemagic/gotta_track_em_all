class AddRejectedCardsFromApiJob < ApplicationJob
  queue_as :default
  
  def perform(cards)
    cards.each do | card_info| 
      # Filter out cards that already exist

      front_image = card_info["images"]&.find { |image| image["type"] == "front" } || card_info["images"]&.first

      card = Card.find_or_create_by!(card_info.dig("id"))
      
      Card.assign_attributes!(
        name: card_info.dig("name"),
        card_number: card_info.dig("printed_number"), 
        artist: card_info.dig("artist"),
        rarity: card_info.dig("rarity"),
        image_url: front_image&.dig("large"),
        pokemon_types: card_info["types"]&.join(", "),
        abilities: card_info.dig("abilities"),
        attacks: card_info.dig("attacks"),
        set_name: card_info.dig("expansion", "name"),
        release_date: PokedataParser.parse_release_date(card_info.dig("expansion", "release_date"))
      ) 

      card.api_tcg_status = card.complete_card_info? ? "complete" : "incomplete"
      card.save!
    end
  end
end
