require "test_helper"
require "minitest/mock"

class FetchCardInfoJobTest < ActiveJob::TestCase
  self.fixture_table_names = []

  test "matches an existing API card from the identified set instead of creating a duplicate" do
    user = User.create!(
      email: "fetch-card-info@example.com",
      password: "password123",
      username: "fetch_card_info_test",
      trainer_type: "pokescientist"
    )
    attempt = SearchAttempt.create!(
      user: user,
      status: "creating_card",
      identified_name: "Ludicolo",
      identified_number: "2/100",
      identified_set_name: "EX Deoxys"
    )
    existing_card = Card.create!(
      api_tcg_id: "ex8-6",
      name: "Ludicolo",
      card_number: "2/100",
      set_name: "EX Deoxys"
    )
    response = Struct.new(:success?, :parsed_response).new(
      true,
      {
        "data" => [
          card_response(id: "det1-2", number: "2/18", set_name: "Detective Pikachu"),
          card_response(id: existing_card.api_tcg_id, number: "2/100", set_name: "EX Deoxys")
        ]
      }
    )

    assert_no_difference("Card.count") do
      assert_enqueued_with(job: FetchCardPricingJob, args: [ existing_card.id ]) do
        HTTParty.stub(:get, response) do
          FetchCardInfoJob.perform_now(attempt.id, user.id)
        end
      end
    end

    attempt.reload
    assert_predicate attempt, :status_matched?
    assert_equal existing_card, attempt.card
    assert_nil attempt.error_message
  end

  test "creates a card from Scrydex metadata and starts pricing" do
    user = User.create!(email: "scrydex-info@example.com", password: "password123",
      username: "scrydex_info_test", trainer_type: "pokescientist")
    attempt = SearchAttempt.create!(user: user, status: "creating_card",
      identified_name: "Ludicolo", identified_number: "2/100", identified_set_name: "EX Deoxys")
    metadata = card_response(id: "ex8-2", number: "2/100", set_name: "EX Deoxys").merge(
      "artist" => "Test Artist", "rarity" => "Rare Holo", "types" => [ "Water", "Grass" ],
      "images" => [ { "type" => "back", "large" => "https://example.com/back.png" },
        { "type" => "front", "large" => "https://example.com/front.png" } ],
      "expansion" => { "name" => "EX Deoxys", "release_date" => "2005/02/14", "language" => "English" }
    )
    response = Struct.new(:success?, :parsed_response).new(true, { "data" => [ metadata ] })
    pricing_card_ids = []

    assert_difference("Card.count", 1) do
      HTTParty.stub(:get, response) do
        FetchCardPricingJob.stub(:perform_now, ->(id) { pricing_card_ids << id }) do
          FetchCardInfoJob.perform_now(attempt.id, user.id)
        end
      end
    end

    attempt.reload
    assert_predicate attempt, :status_matched?
    assert_predicate attempt.card, :status_complete?
    assert_equal "https://example.com/front.png", attempt.card.image_url
    assert_equal "Water, Grass", attempt.card.pokemon_types
    assert_equal "English", attempt.card.language
    assert_equal Date.new(2005, 2, 14), attempt.card.release_date
    assert_equal [ attempt.card_id ], pricing_card_ids
  end

  test "matches by first ability or attack across pages despite a different set name" do
    user = User.create!(email: "paged@example.com", password: "password123",
      username: "paged_test", trainer_type: "pokescientist")
    attempt = SearchAttempt.create!(user: user, status: "creating_card",
      identified_name: "Ludicolo", identified_number: "2/100",
      identified_set_name: "Misidentified set", identified_moves: "Rain-Dish")
    existing = Card.create!(api_tcg_id: "target", name: "Ludicolo",
      card_number: "2/100", set_name: "Actual set")
    wrong = card_response(id: "wrong", number: "2/100", set_name: "Misidentified set").merge(
      "abilities" => [{ "name" => "Other ability" }], "attacks" => [{ "name" => "Rain Dish" }])
    target = card_response(id: "target", number: "2/100", set_name: "Actual set").merge(
      "abilities" => [{ "name" => "Rain Dish" }])
    pages = []
    fetch = lambda do |_url, **options|
      page = options[:query][:page]
      pages << page
      raise "Unnecessary page requested" if page > 2
      Struct.new(:success?, :parsed_response).new(true,
        { "data" => [page == 1 ? wrong : target], "pageSize" => 1, "totalCount" => 3 })
    end
    HTTParty.stub(:get, fetch) { FetchCardInfoJob.perform_now(attempt.id, user.id) }
    assert_equal [1, 2], pages
    assert_equal existing, attempt.reload.card
    assert_predicate attempt, :status_matched?
  end

  test "uses the first attack when there is no ability and rejects missing moves" do
    attempt = SearchAttempt.new(identified_name: "Ludicolo", identified_number: "2/100",
      identified_set_name: "Wrong set", identified_moves: "  Solar Wind! ")
    candidate = card_response(id: "target", number: "2/100", set_name: "Actual set").merge(
      "abilities" => [], "attacks" => [{ "name" => "Solar Wind" }])
    job = FetchCardInfoJob.new
    assert job.send(:matches_identification?, candidate, attempt)
    candidate["attacks"] = [{ "name" => "Other" }, { "name" => "Solar Wind" }]
    assert_not job.send(:matches_identification?, candidate, attempt)
    candidate["attacks"] = []
    assert_not job.send(:matches_identification?, candidate, attempt)
  end

  test "stops after the final page when no card matches" do
    user = User.create!(email: "unmatched@example.com", password: "password123",
      username: "unmatched_test", trainer_type: "pokescientist")
    attempt = SearchAttempt.create!(user: user, status: "creating_card",
      identified_name: "Ludicolo", identified_number: "2/100", identified_moves: "Rain Dish")
    pages = []
    fetch = lambda do |_url, **options|
      page = options[:query][:page]
      pages << page
      raise "Unnecessary page requested" if page > 2
      Struct.new(:success?, :parsed_response).new(true,
        { "data" => [card_response(id: "wrong-#{page}", number: "2/100", set_name: "Other")],
          "pageSize" => 1, "totalCount" => 2 })
    end
    HTTParty.stub(:get, fetch) { FetchCardInfoJob.perform_now(attempt.id, user.id) }
    assert_equal [1, 2], pages
    assert_predicate attempt.reload, :status_failed?
  end

  private

  def card_response(id:, number:, set_name:)
    {
      "id" => id,
      "name" => "Ludicolo",
      "printed_number" => number,
      "number" => number.split("/").first,
      "expansion" => { "name" => set_name }
    }
  end
end
