require "test_helper"

class ScrydexIdentificationJobTest < ActiveJob::TestCase
  test "HTTP 401 raises the non-retryable authentication error and logs the response" do
    response = Struct.new(:success?, :code, :body).new(
      false,
      401,
      '{"message":"Invalid API key"}'
    )
    logger = Minitest::Mock.new
    logger.expect(
      :error,
      nil,
      [ "Scrydex vision request failed with HTTP 401; response: {\"message\":\"Invalid API key\"}" ]
    )

    Rails.stub(:logger, logger) do
      error = assert_raises(ScrydexIdentificationJob::ScrydexAuthenticationError) do
        ScrydexIdentificationJob.new.send(:ensure_success!, response, "vision")
      end
      assert_equal "Scrydex vision request failed with HTTP 401", error.message
    end

    logger.verify
  end

  test "other HTTP failures remain retryable identification errors" do
    response = Struct.new(:success?, :code, :body).new(false, 503, "Unavailable")

    Rails.logger.stub(:error, nil) do
      assert_raises(ScrydexIdentificationJob::ScrydexIdentificationError) do
        ScrydexIdentificationJob.new.send(:ensure_success!, response, "vision")
      end
    end
  end
end
