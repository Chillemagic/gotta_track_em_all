# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all
Collection.destroy_all

user1 = User.create!(
  email: "user1@mail.com",
  password: "secret",
  username: "user1"
)

pokemon_collections = [
  { name: "Kanto Starters", description: "A collection featuring Bulbasaur, Charmander, and Squirtle evolutions.", user: user1 },
  { name: "Legendary Birds", description: "Articuno, Zapdos, and Moltres from the original Pokémon series.", user: user1 },
  { name: "Eeveelutions", description: "A complete set of Eevee and all its evolutions up to Sylveon.", user: user1 },
  { name: "Team Rocket Edition", description: "Dark versions of classic Pokémon from the Team Rocket expansion.", user: user1 },
  { name: "Shiny Pokémon", description: "Rare shiny variant cards collected over years of trading.", user: user1 },
  { name: "Gym Leaders’ Favorites", description: "Pokémon used by iconic Gym Leaders like Misty and Brock.", user: user1 },
  { name: "Legendary Beasts", description: "Raikou, Entei, and Suicune cards from the Johto region.", user: user1 },
  { name: "Mythical Pokémon", description: "Mew, Celebi, Jirachi, and other elusive mythical Pokémon.", user: user1 },
  { name: "Mega Evolutions", description: "Pokémon that can Mega Evolve, such as Mega Charizard and Mega Lucario.", user: user1 },
  { name: "Sword & Shield Era", description: "Pokémon introduced in the Galar region, including Zacian and Zamazenta.", user: user1 }
]

pokemon_collections.each do |hash|
  Collection.create!(hash)
end
