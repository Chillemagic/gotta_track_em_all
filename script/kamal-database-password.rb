# Read credentials without booting initializers or connecting to the database.
# Output is consumed by Kamal; do not run this directly in a shared terminal.
ENV["RAILS_ENV"] = "production"
require_relative "../config/application"

password = ENV["GOTTA_TRACK_EM_ALL_DATABASE_PASSWORD"] ||
  Rails.application.credentials.dig(:database, :password)

abort "Set database.password in Rails credentials before deploying PostgreSQL" if password.blank?

print password
