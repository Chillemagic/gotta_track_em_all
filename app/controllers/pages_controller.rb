class PagesController < ApplicationController
  layout "root_layout"

  before_action :authenticate_user!, except: :home

  def home
    # dashboard or landing page for logged-in users
    redirect_to users_home_path if user_signed_in?
  end
end
