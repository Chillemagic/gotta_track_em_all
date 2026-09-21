unless ENV["SECRET_KEY_BASE_DUMMY"]
  OpenAI.configure do |config|
    config.access_token =
      Rails.application.credentials.openai.fetch(:api_key)
  end
end
