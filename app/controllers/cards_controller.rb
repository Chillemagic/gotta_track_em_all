class CardsController < ApplicationController
  before_action :set_card, only: %i[show destroy]

  def index
    @cards = Card.all
  end

  def show
  end

  def new
    @card = Card.new
  end

  def create
    @card = Card.new(card_params)
    if @card.save
      redirect_to @card, notice: "Card was successfully added to your collection."
    else
      render :new
    end
  end

  def destroy
    @card.destroy
    redirect_to cards_url, notice: "Card was successfully removed from your collection."
  end

  private

  def set_card
    @cards = Card.find(params[:id])
  end

  def card_params
  params.require(:card).permit(
    :card_api_id,
    :name,
    :card_number,
    :pokemon_set,
    :release_date,
    :artist,
    :rarity,
    :image_url,
    :pokemon_types,
    :finish_type
  )
  end
end
