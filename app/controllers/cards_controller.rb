class CardsController < ApplicationController
  before_action :authenticate_user! # for Devise
  def def new
    @card = Card.new
  end

  def create
  end
end
