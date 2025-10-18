require "json"

file_path = Rails.root.join("db", "seeds", "pokemon_cards.json")
cards = JSON.parse(File.read(file_path))

cards.each do |card|
  debugger
end
