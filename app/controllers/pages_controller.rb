class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    # dashboard or landing page for logged-in users
  end
end
