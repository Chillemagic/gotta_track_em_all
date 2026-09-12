require "base64"
class CardsController < ApplicationController
  layout "background_pattern_dark"

  before_action :authenticate_user! # for Devise
  before_action :set_card, only: %i[show destroy]


  def index
    @cards = Card.all
  end

  def show
    @collection = Collection.new
    @collection_card ||= CollectionCard.new(card: @card, condition: "Raw")
    @collection ||= Collection.new

    pricing_history = @card.price_histories.last
    if pricing_history
      pricing_hash = pricing_history.attributes["pricing_data"]
      grading_keys = pricing_hash.keys
                                 .select { |k| k.match?(/\A(PSA|CGC)\s*\d+(\.\d+)?\z/) }
                                 .sort_by { |k| k[/\d+(\.\d+)?/].to_f }
      raw_keys = pricing_hash.keys.select { |k| k.downcase.include?("raw") }
      @condition_options = raw_keys + grading_keys
    else
      @condition_options = [ "Raw" ] + (1..10).flat_map { |n| [ "CGC #{n}.0", "PSA #{n}.0" ] }
    end
  end

  # def retry_with_scrydex
  #  @card = Card.find(params[:id])
  #  # Changes and checks
  #  # ScrydexVisionIdentificationJob.perform_later(@card.id)
  # end

  def search
     @holo_options = [
      "Standard",
      "Holo (The Pokemon artwork is shiny)",
      "Reverse Holo (The part outside the artwork
      is shiny)"
    ]

    return unless request.post?

    uploaded_image = params.dig(:search, :image)

    unless uploaded_image.present?
      flash.now[:alert] = "Please upload an image."
      return render :search,
      status: :unprocessable_entity
    end

    @search_attempt = current_user.search_attempts.create!(
      status: "pending",
      holo_type: params.dig(:search, :holo_type)
    )

    @search_attempt.image.attach(uploaded_image)

    IdentifyCardJob.perform_later(@search_attempt.id, current_user.id)

    redirect_to @search_attempt
  end
  #   _________________________________________________________________________________
  #    @holo_options = [ "Standard", "Holo (The Pokemon artwork is shiny)", "Reverse Holo (The part outside the artwork is shiny)" ]
  #
  #    if params[:search]  && params[:search][:image].present?
  #
  #      @card = Card.create!(
  #        status: "processing",
  #        holo_type: params[:search][:holo_type],
  #      )
  #
  #      @card.image.attach(params[:search][:image])
  #
  #      upload = Base64.strict_encode64(params[:search][:image].read)
  #      IdentifyCardJob.perform_later(@card.id, upload, current_user.id)
  #      redirect_to @card
  #    end
  #  end

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
    @card = Card.find(params[:id])
  end

  def card_params
  params.require(:card).permit(
    :api_tcg_id,
    :name,
    :card_number,
    :pokemon_set,
    :release_date,
    :artist,
    :rarity,
    :image,
    :image_url,
    :pokemon_types,
    :finish_type,
    :holo_type
  )
  end
end
