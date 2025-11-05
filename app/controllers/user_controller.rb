class UserController < ApplicationController
  def check_username
    username = params[:username].to_s.strip.downcase
    exists = User.where("lower(username) = ?", username).exists?

    render partial: "users/username_feedback", locals: { exists: exists }
  end
end
