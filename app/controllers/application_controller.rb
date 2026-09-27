class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  layout "application"
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller? && %w[sessions registrations].include?(controller_name) && %w[new create].include?(action_name)
      return "root_layout"
    end

    devise_controller? ? "background_nature" : "application"
  end


  def configure_permitted_parameters
     devise_parameter_sanitizer.permit(:sign_up, keys: %i[email trainer_type first_name last_name username date_of_birth preset_avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email trainer_type first_name last_name username date_of_birth])
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[login])
  end
end
