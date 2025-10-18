Pokemon.configure do |config|
  config.api_key = ENV.fetch("POKEMON_TCG_API_KEY")
end
