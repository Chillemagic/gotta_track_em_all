class Users::RegistrationsController < Devise::RegistrationsController
  def update
    # Remove uploaded avatar if user selects a preset avatart
    if params[:user][:preset_avatar].present?
      resource.avatar.purge if resource.avatar.attached?
    end

    # Remove preset avatart if user uploads new avatar
    if params[:user][:avatar].present?
      params[:user][:preset_avatar] = nil
    end

    super
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :trainer_type, :avatar, :preset_avatar)
  end

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :trainer_type, :avatar, :preset_avatar)
  end
end
