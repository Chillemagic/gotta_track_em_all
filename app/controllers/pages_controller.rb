class PagesController < ApplicationController
  layout "background_nature"
  before_action :authenticate_user!

  def home
    # dashboard or landing page for logged-in users
  end
end
