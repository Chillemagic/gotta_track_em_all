require "test_helper"
require "minitest/mock"

class IdentifyCardJobTest < ActiveJob::TestCase
  self.fixture_table_names = []

  setup do
    user = User.create!(email: "identify@example.com", password: "password123",
                        username: "identify_test", trainer_type: "pokescientist")
    @attempt = SearchAttempt.create!(user: user, status: "pending")
    @job = IdentifyCardJob.new
    @info = { "name" => "Ludicolo", "number" => "2/100", "set_name" => "Crystal Guardians", "first_card_ability_or_attack" => "Rain Dish" }
  end

  test "an unknown card queues the info job with IDs and a valid status" do
    identify do
      assert_enqueued_with(job: FetchCardInfoJob, args: [@attempt.id, @attempt.user_id]) do
        @job.perform(@attempt.id, @attempt.user_id)
      end
    end

    assert_predicate @attempt.reload, :status_creating_card?
    assert_equal "Ludicolo", @attempt.identified_name
    assert_equal "2/100", @attempt.identified_number
    assert_equal "Rain Dish", @attempt.identified_moves
  end

  test "missing images fail the search" do
    assert_no_enqueued_jobs do
      @job.perform(@attempt.id, @attempt.user_id)
    end
    assert_predicate @attempt.reload, :status_failed?
    assert_equal "No image provided", @attempt.error_message
  end

  test "API errors fail the search without queuing another job" do
    identify({ "error" => "OpenAI API error: timed out" }) do
      assert_no_enqueued_jobs { @job.perform(@attempt.id, @attempt.user_id) }
    end
    assert_predicate @attempt.reload, :status_failed?
    assert_equal "OpenAI API error: timed out", @attempt.error_message
  end

  test "unexpected exceptions are recorded and raised for the queue" do
    identify do
      @job.stub(:find_match, ->(*) { raise "Matching failed" }) do
        assert_raises(RuntimeError) { @job.perform(@attempt.id, @attempt.user_id) }
      end
    end
    assert_predicate @attempt.reload, :status_failed?
    assert_equal "Matching failed", @attempt.error_message
  end

  test "API failures use the error key consumed by perform" do
    OpenAI::Client.stub(:new, -> { raise "Unavailable" }) do
      assert_equal({ "error" => "OpenAI API error: Unavailable" }, @job.identify_card_with_api("image"))
    end
  end

  private

  def identify(info = @info, &block)
    # Keep image storage and external identification offline.
    User.stub(:find, @attempt.user) do
      @attempt.user.search_attempts.stub(:find, @attempt) do
        @attempt.image.stub(:attached?, true) do
          @job.stub(:image_data_url, "data:image/jpeg;base64,test") do
            @job.stub(:identify_card_with_api, info, &block)
          end
        end
      end
    end
  end
end
