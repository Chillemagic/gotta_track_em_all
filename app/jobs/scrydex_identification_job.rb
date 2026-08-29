class ScrydexIdentificationJob < ApplicationJob
  queue_as :default

  def perform(card_id, image_url)
    @card = Card.find(card_id)  

      body = {
        image_url: image_url,
        games: ["pokemon"]
      }
      
      # Find Card With Vision 
      response = HTTParty.post(

        "https://api.scrydex.com/vision/v1/cards/identify",
        headers: {
          "Content-Type" => "application/json",
          "X-Api-Key" => ENV.fetch("SCRYDEX_API_KEY"),
          "X-Team-ID" => "gtea"
        },
        body: body.to_json
      )
    # Do something later
  end
end
