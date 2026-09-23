class Users::RegistrationsController < Devise::RegistrationsController
  protected

  PASSWORD_FIELDS = %i[
    password,
    password_confirmation,
    current_password
  ]

  def update_resource(resource, params)
    # Removes preset avatar
    if params.dig(:user, :avatar).present?
      params[:user][:preset_avatar] = nil
    end

    if params[:password].present?
      resource.update_with_password(params)
    else
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)

      resource.update_without_password(params.except(*PASSWORD_FIELDS))
    end
  end

  private

  def account_update_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :username,
      :password,
      :password_confirmation,
      :current_password,
      :trainer_type,
      :avatar,
      :preset_avatar)
  end
end
