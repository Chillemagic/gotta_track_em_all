# require "pokemon_tcg_sdk"

# Pokemon.configure do |config|
#   config.api_key = Rails.application.credentials.dig(:pokemon_tcg, :api_key)
# end

# module Pokemon
#   class Card
#     class << self
#       def connection
#         @connection ||= Faraday.new(url: "https://api.pokemontcg.io/v2/") do |faraday|
#           faraday.request :url_encoded
#           faraday.adapter Faraday.default_adapter
#           faraday.options.timeout = 30
#           faraday.options.open_timeout = 10
#         end
#       end
#     end
#   end
# end
