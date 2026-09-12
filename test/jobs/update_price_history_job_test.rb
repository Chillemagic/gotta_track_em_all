require "test_helper"
require "minitest/mock"

class UpdatePriceHistoryJobTest < ActiveJob::TestCase
  self.fixture_table_names = []

  Response = Data.define(:success?, :code, :parsed_response)

  setup do
    @card = Card.create!(
      api_tcg_id: "base1-4",
      name: "Charizard",
      card_number: "4/102",
      holo_type: "Holo"
    )
  end

  test "creates a price history from a successful response" do
    response = Response.new(
      true,
      200,
      {
        "data" => [
          {
            "id" => "base1-4",
            "name" => "Charizard",
            "printed_number" => "4/102",
            "expansion" => {
              "name" => "Base Set",
              "release_date" => "1999-01-09"
            },
            "variants" => [
              {
                "name" => "holofoil",
                "prices" => [
                  {
                    "type" => "raw",
                    "condition" => "NM",
                    "market" => 250.0
                  }
                ]
              }
            ]
          }
        ]
      }
    )

    assert_difference("@card.price_histories.count", 1) do
      HTTParty.stub(:get, response) do
        UpdatePriceHistoryJob.perform_now(@card.id)
      end
    end

    assert_equal 250.0, @card.price_histories.last.pokedata_raw_price
  end

  test "does not create a price history when Scrydex returns no card data" do
    response = Response.new(true, 200, { "data" => [] })

    assert_no_difference("@card.price_histories.count") do
      HTTParty.stub(:get, response) do
        UpdatePriceHistoryJob.perform_now(@card.id)
      end
    end
  end

  test "does not create a price history when no raw price is available" do
    response = Response.new(
      true,
      200,
      {
        "data" => [
          {
            "id" => "base1-4",
            "variants" => [ { "name" => "holofoil", "prices" => [] } ]
          }
        ]
      }
    )

    assert_no_difference("@card.price_histories.count") do
      HTTParty.stub(:get, response) do
        UpdatePriceHistoryJob.perform_now(@card.id)
      end
    end
  end

  test "raises a retryable error when Scrydex returns an unsuccessful response" do
    response = Response.new(false, 503, {})

    error = assert_raises(UpdatePriceHistoryJob::PricingRequestError) do
      HTTParty.stub(:get, response) do
        UpdatePriceHistoryJob.new.perform(@card.id)
      end
    end

    assert_includes error.message, "HTTP 503"
  end
end
