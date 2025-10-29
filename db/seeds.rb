# require "json"
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
CollectionCard.destroy_all
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




# file_path = Rails.root.join("db", "seeds", "pokemon_cards.json")
# cards = JSON.parse(File.read(file_path))

# cards.each do |card|
#   debugger
# end
puts "cleaning database 🧹"
Card.delete_all

# cards = Pokemon::Card.where(q: "name:Charizard")

cards = [
  {
    "id" => "base1-4",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "120",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "attacks" => [
      {
        "name" => "Energy Burn",
        "cost" => ["Fire"],
        "convertedEnergyCost" => 1,
        "damage" => "",
        "text" => "As often as you like during your turn (before your attack), you may turn all Energy attached to Charizard into Fire Energy for the rest of the turn. This power can't be used if Charizard is Asleep, Confused, or Paralyzed."
      },
      {
        "name" => "Fire Spin",
        "cost" => ["Fire", "Fire", "Fire", "Fire"],
        "convertedEnergyCost" => 4,
        "damage" => "100",
        "text" => "Discard 2 Energy cards attached to Charizard in order to use this attack."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "retreatCost" => ["Colorless", "Colorless", "Colorless"],
    "convertedRetreatCost" => 3,
    "set" => {
      "id" => "base1",
      "name" => "Base",
      "series" => "Base",
      "printedTotal" => 102,
      "total" => 102,
      "legalities" => {"unlimited" => "Legal"},
      "releaseDate" => "1999/01/09",
      "updatedAt" => "2020/08/14 09:35:00"
    },
    "number" => "4",
    "artist" => "Mitsuhiro Arita",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/base1/4.png",
      "large" => "https://images.pokemontcg.io/base1/4_hires.png"
    },
    "tcgplayer" => {
      "url" => "https://prices.pokemontcg.io/tcgplayer/base1-4",
      "updatedAt" => "2025/10/18",
      "prices" => {
        "holofoil" => {
          "low" => 250.00,
          "mid" => 350.00,
          "high" => 500.00,
          "market" => 320.00
        }
      }
    }
  },
  {
    "id" => "xy2-12",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "150",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "abilities" => [
      {
        "name" => "Combustion Blast",
        "text" => "Discard an Energy attached to this Pokémon.",
        "type" => "Ability"
      }
    ],
    "attacks" => [
      {
        "name" => "Fire Blast",
        "cost" => ["Fire", "Fire", "Colorless", "Colorless"],
        "convertedEnergyCost" => 4,
        "damage" => "120",
        "text" => "Discard an Energy card attached to this Pokémon."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "resistances" => [{"type" => "Fighting", "value" => "-20"}],
    "retreatCost" => ["Colorless", "Colorless"],
    "convertedRetreatCost" => 2,
    "set" => {
      "id" => "xy2",
      "name" => "Flashfire",
      "series" => "XY",
      "printedTotal" => 106,
      "total" => 110,
      "releaseDate" => "2014/05/07"
    },
    "number" => "12",
    "artist" => "Kagemaru Himeno",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/xy2/12.png",
      "large" => "https://images.pokemontcg.io/xy2/12_hires.png"
    }
  },
  {
    "id" => "swsh9-18",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "170",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "attacks" => [
      {
        "name" => "Heat Blast",
        "cost" => ["Fire", "Colorless"],
        "convertedEnergyCost" => 2,
        "damage" => "50",
        "text" => ""
      },
      {
        "name" => "Burning Darkness",
        "cost" => ["Fire", "Fire", "Colorless"],
        "convertedEnergyCost" => 3,
        "damage" => "100+",
        "text" => "This attack does 30 more damage for each Darkness Energy attached to all of your Pokémon."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "retreatCost" => ["Colorless", "Colorless", "Colorless"],
    "convertedRetreatCost" => 3,
    "set" => {
      "id" => "swsh9",
      "name" => "Brilliant Stars",
      "series" => "Sword & Shield",
      "printedTotal" => 172,
      "total" => 186,
      "releaseDate" => "2022/02/25"
    },
    "number" => "18",
    "artist" => "Kouki Saitou",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/swsh9/18.png",
      "large" => "https://images.pokemontcg.io/swsh9/18_hires.png"
    }
  }
]

cards.each do |card|
  Card.create!(
    # name: c.name,
    # set_name: c.set.name,
    # release_date: c.set.release_date,
    # rarity: c.rarity,
    # image_url: c.images.large

    name: card['name'],
    set_name: card['set']["name"],
    release_date: card['set']["releaseDate"],
    rarity: card["rarity"],
    image_url: card["images"]["large"],
    card_api_id: card["id"]
  )
  puts "created new card"
end


puts "cleaning database 🧹"
Card.delete_all

# cards = Pokemon::Card.where(q: "name:Charizard")

cards = [
  {
    "id" => "base1-4",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "120",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "attacks" => [
      {
        "name" => "Energy Burn",
        "cost" => ["Fire"],
        "convertedEnergyCost" => 1,
        "damage" => "",
        "text" => "As often as you like during your turn (before your attack), you may turn all Energy attached to Charizard into Fire Energy for the rest of the turn. This power can't be used if Charizard is Asleep, Confused, or Paralyzed."
      },
      {
        "name" => "Fire Spin",
        "cost" => ["Fire", "Fire", "Fire", "Fire"],
        "convertedEnergyCost" => 4,
        "damage" => "100",
        "text" => "Discard 2 Energy cards attached to Charizard in order to use this attack."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "retreatCost" => ["Colorless", "Colorless", "Colorless"],
    "convertedRetreatCost" => 3,
    "set" => {
      "id" => "base1",
      "name" => "Base",
      "series" => "Base",
      "printedTotal" => 102,
      "total" => 102,
      "legalities" => {"unlimited" => "Legal"},
      "releaseDate" => "1999/01/09",
      "updatedAt" => "2020/08/14 09:35:00"
    },
    "number" => "4",
    "artist" => "Mitsuhiro Arita",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/base1/4.png",
      "large" => "https://images.pokemontcg.io/base1/4_hires.png"
    },
    "tcgplayer" => {
      "url" => "https://prices.pokemontcg.io/tcgplayer/base1-4",
      "updatedAt" => "2025/10/18",
      "prices" => {
        "holofoil" => {
          "low" => 250.00,
          "mid" => 350.00,
          "high" => 500.00,
          "market" => 320.00
        }
      }
    }
  },
  {
    "id" => "xy2-12",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "150",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "abilities" => [
      {
        "name" => "Combustion Blast",
        "text" => "Discard an Energy attached to this Pokémon.",
        "type" => "Ability"
      }
    ],
    "attacks" => [
      {
        "name" => "Fire Blast",
        "cost" => ["Fire", "Fire", "Colorless", "Colorless"],
        "convertedEnergyCost" => 4,
        "damage" => "120",
        "text" => "Discard an Energy card attached to this Pokémon."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "resistances" => [{"type" => "Fighting", "value" => "-20"}],
    "retreatCost" => ["Colorless", "Colorless"],
    "convertedRetreatCost" => 2,
    "set" => {
      "id" => "xy2",
      "name" => "Flashfire",
      "series" => "XY",
      "printedTotal" => 106,
      "total" => 110,
      "releaseDate" => "2014/05/07"
    },
    "number" => "12",
    "artist" => "Kagemaru Himeno",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/xy2/12.png",
      "large" => "https://images.pokemontcg.io/xy2/12_hires.png"
    }
  },
  {
    "id" => "swsh9-18",
    "name" => "Charizard",
    "supertype" => "Pokémon",
    "subtypes" => ["Stage 2"],
    "hp" => "170",
    "types" => ["Fire"],
    "evolvesFrom" => "Charmeleon",
    "attacks" => [
      {
        "name" => "Heat Blast",
        "cost" => ["Fire", "Colorless"],
        "convertedEnergyCost" => 2,
        "damage" => "50",
        "text" => ""
      },
      {
        "name" => "Burning Darkness",
        "cost" => ["Fire", "Fire", "Colorless"],
        "convertedEnergyCost" => 3,
        "damage" => "100+",
        "text" => "This attack does 30 more damage for each Darkness Energy attached to all of your Pokémon."
      }
    ],
    "weaknesses" => [{"type" => "Water", "value" => "×2"}],
    "retreatCost" => ["Colorless", "Colorless", "Colorless"],
    "convertedRetreatCost" => 3,
    "set" => {
      "id" => "swsh9",
      "name" => "Brilliant Stars",
      "series" => "Sword & Shield",
      "printedTotal" => 172,
      "total" => 186,
      "releaseDate" => "2022/02/25"
    },
    "number" => "18",
    "artist" => "Kouki Saitou",
    "rarity" => "Rare Holo",
    "nationalPokedexNumbers" => [6],
    "images" => {
      "small" => "https://images.pokemontcg.io/swsh9/18.png",
      "large" => "https://images.pokemontcg.io/swsh9/18_hires.png"
    }
  }
]

cards.each do |card|
  Card.create!(
    # name: c.name,
    # set_name: c.set.name,
    # release_date: c.set.release_date,
    # rarity: c.rarity,
    # image_url: c.images.large

    name: card['name'],
    set_name: card['set']["name"],
    release_date: card['set']["releaseDate"],
    rarity: card["rarity"],
    image_url: card["images"]["large"],
    card_api_id: card["id"]
  )
  puts "created new card"
end

Collection.all.each do |collection|
  Card.all.each do |card|
    CollectionCard.create!(
      card: card,
      collection: collection
    )
  end
end
