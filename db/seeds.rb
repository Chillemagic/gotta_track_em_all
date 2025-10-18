# require "json"

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
