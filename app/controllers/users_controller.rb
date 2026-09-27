class UsersController < ApplicationController
  layout "background_nature"

  def check_username
    exists = User.exists?(username: params[:username])
    render json: { available: !exists }
  end
end
