unless ENV["SECRET_KEY_BASE_DUMMY"]
  Cloudinary.config do |config|
    config.cloud_name = Rails.application.credentials.dig(:cloudinary, :cloud_name)
    config.api_key = Rails.application.credentials.dig(:cloudinary, :api_key)
    config.api_secret = Rails.application.credentials.dig(:cloudinary, :secret_key)
  end
end
