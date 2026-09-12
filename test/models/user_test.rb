require "test_helper"

class UserTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    @user = User.create!(email: "price-average@example.com", password: "password123",
      username: "price_average_test", trainer_type: "pokescientist")
    @collection = @user.collections.create!(name: "Test collection")
  end

  test "averages selected condition prices including zero and excludes unavailable prices" do
    card = Card.create!(name: "Charizard")
    card.price_histories.create!(source: "Scrydex", recorded_at: Time.current,
      pokedata_raw_price: 100, pricing_data: {
        "Raw" => { "value" => 100 },
        "holofoil Raw LP" => { "value" => 20 },
        "PSA 10" => { "value" => 70 },
        "holofoil Raw DM" => { "value" => 0 }
      })
    [ "holofoil Raw LP", "PSA 10", "holofoil Raw DM", "CGC 10" ].each do |condition|
      @collection.collection_cards.create!(card: card, condition: condition)
    end

    assert_equal 30.0, @user.average_card_price
    assert_equal 90.0, @user.total_card_value
  end

  test "returns zero for an empty collection or a collection with no known prices" do
    assert_equal 0.0, @user.average_card_price

    @collection.collection_cards.create!(card: Card.create!(name: "Unpriced"), condition: "Raw")
    assert_equal 0.0, @user.average_card_price
  end
end
