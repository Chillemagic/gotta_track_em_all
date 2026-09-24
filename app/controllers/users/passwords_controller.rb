class Users::PasswordsController < Devise::PasswordsController
  rate_limit to: 3, within: 5.minutes,
    name: "ip", only: :create,
    with: :rate_limit_exceeded

  rate_limit to: 3, within: 1.hour,
    name: "email", only: :create,
    by: -> { params.dig(:user, :email).to_s.strip.downcase },
    with: :rate_limit_exceeded

  private

  def rate_limit_exceeded
    redirect_to new_user_password_path,
      alert: "Too many requests, try again later."
  end
end
