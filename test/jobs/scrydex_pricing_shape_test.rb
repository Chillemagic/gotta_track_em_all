require "test_helper"
require "minitest/mock"

class ScrydexPricingShapeTest < ActiveJob::TestCase
  self.fixture_table_names = []

  [ FetchCardPricingJob, UpdatePriceHistoryJob ].each do |job_class|
    test "#{job_class} keeps raw and graded variant prices distinct" do
      card = Card.create!(api_tcg_id: "base1-4", name: "Charizard", holo_type: "Holo")
      graded = {
        "type" => "graded", "company" => "PSA", "grade" => "10",
        "is_perfect" => false, "is_signed" => false, "is_error" => false,
        "low" => 2350.0, "mid" => 2566.0, "high" => 2650.0,
        "market" => 2567.88, "currency" => "USD",
        "trends" => { "days_1" => { "price_change" => 111.75, "percent_change" => 4.55 } }
      }
      payload = {
        "id" => card.api_tcg_id, "name" => card.name,
        "printed_number" => "4/102",
        "expansion" => { "name" => "Base", "release_date" => "1999/01/09" },
        "variants" => [
          { "name" => "holofoil", "prices" => [
            { "type" => "raw", "condition" => "NM", "market" => 250.0, "currency" => "USD" },
            graded,
            graded.merge("is_signed" => true, "market" => 3000.0),
            graded.merge("company" => "CGC", "grade" => "9.5", "market" => nil),
            graded.merge("company" => "CGC", "is_perfect" => true),
            graded.merge("is_error" => true),
            graded.merge("company" => "BGS")
          ] },
          { "name" => "reverseHolofoil", "prices" => [ graded.merge("market" => 100.0) ] },
          { "name" => "normal", "prices" => nil }
        ]
      }
      response = Struct.new(:success?, :parsed_response).new(true, { "data" => [ payload ] })
      request = lambda do |url, options|
        assert_equal "https://api.scrydex.com/pokemon/v1/cards", url
        assert_equal({ q: "id:base1-4", include: "prices" }, options[:query])
        response
      end

      assert_difference("card.price_histories.count", 1) do
        HTTParty.stub(:get, request) { job_class.perform_now(card.id) }
      end

      history = card.price_histories.last
      assert_equal 250.0, history.pokedata_raw_price
      assert_equal 250.0, history.pricing_data.dig("holofoil Raw NM", "value")
      assert_equal 2567.88, history.psa_pricing.dig("PSA 10", "value")
      assert_equal 3000.0, history.psa_pricing.dig("PSA 10 Signed", "value")
      assert_equal 2567.88, history.psa_pricing.dig("PSA 10 Error", "value")
      assert_equal 2566.0, history.cgc_pricing.dig("CGC 9.5", "value")
      assert_equal 2567.88, history.cgc_pricing.dig("CGC 10 Perfect", "value")
      assert_equal 100.0, history.pricing_data.dig("reverseHolofoil PSA 10 USD", "value")
      assert_equal graded["trends"], history.pricing_data.dig("PSA 10", "trends")
      assert_equal 2567.88, history.pricing_data.dig("holofoil BGS 10 USD", "value")
      assert_nil history.pricing_data["holofoil Raw "]
    end
  end
end
