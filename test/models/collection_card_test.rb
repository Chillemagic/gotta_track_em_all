require "test_helper"

class CollectionCardTest < ActiveSupport::TestCase
  self.fixture_table_names = []

  setup do
    @card = Card.create!(name: "Charizard")
    @collection_card = CollectionCard.new(card: @card, condition: "holofoil Raw LP")
  end

  test "uses the selected raw condition and variant instead of the generic raw price" do
    create_history(pricing_data: {
      "Raw" => { "value" => 100 },
      "holofoil Raw LP" => { "value" => 25.126 },
      "reverseHolofoil Raw LP" => { "value" => 15 }
    })

    assert_equal 25.13, @collection_card.fetch_price
    @collection_card.condition = "reverseHolofoil Raw LP"
    assert_equal 15.0, @collection_card.fetch_price
    @collection_card.condition = "Raw"
    assert_equal 100.0, @collection_card.fetch_price
  end

  test "looks up graded prices including special grades and other companies" do
    prices = {
      "PSA 10" => { "value" => 500 },
      "CGC 10 Perfect" => { "value" => 600 },
      "holofoil BGS 9.5 Signed USD" => { "value" => 700 }
    }
    create_history(pricing_data: prices)

    prices.each do |condition, price|
      @collection_card.condition = condition
      assert_equal price["value"], @collection_card.fetch_price
    end
  end

  test "supports older company-specific price fields" do
    create_history(pricing_data: nil,
      psa_pricing: { "PSA 9" => { "value" => 90 } },
      cgc_pricing: { "CGC 9.5" => { "value" => 95 } })

    @collection_card.condition = "PSA 9"
    assert_equal 90.0, @collection_card.fetch_price
    @collection_card.condition = "CGC 9.5"
    assert_equal 95.0, @collection_card.fetch_price
  end

  test "missing prices return nil without falling back to a different condition" do
    assert_nil @collection_card.fetch_price
    create_history(pricing_data: { "Raw" => { "value" => 100 } },
      psa_pricing: nil, cgc_pricing: nil)

    [ "holofoil Raw LP", "PSA 10", "Unknown", nil ].each do |condition|
      @collection_card.condition = condition
      assert_nil @collection_card.fetch_price
    end
  end

  test "zero is a known price" do
    create_history(pricing_data: { "holofoil Raw LP" => { "value" => 0 } })
    assert_equal 0.0, @collection_card.fetch_price
  end

  test "uses the most recently recorded history even if older history was inserted later" do
    create_history(recorded_at: Time.current, pricing_data: { "holofoil Raw LP" => { "value" => 20 } })
    create_history(recorded_at: 1.day.ago, pricing_data: { "holofoil Raw LP" => { "value" => 10 } })
    assert_equal 20.0, @collection_card.fetch_price
  end

  private

  def create_history(**attributes)
    @card.price_histories.create!({
      source: "Scrydex", recorded_at: Time.current, pokedata_raw_price: 100
    }.merge(attributes))
  end
end
