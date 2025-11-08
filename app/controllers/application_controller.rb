class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[email trainer_type first_name last_name username date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email trainer_type first_name last_name username date_of_birth])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[login])
  end
end
