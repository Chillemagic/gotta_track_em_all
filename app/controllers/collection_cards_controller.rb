class CollectionCardsController < ApplicationController
  before_action :set_collection_card, only: %i[ show edit update destroy ]

  layout "background_pattern_dark"

  # GET /collection_cards or /collection_cards.json
  def index
    @collection_cards = CollectionCard.all
  end

  # GET /collection_cards/1 or /collection_cards/1.json
  def show
    # Fetch most recent price and assign it to price_history
    price_history = @collection_card.card.price_histories.last
    condition = @collection_card.condition
    @collection = @collection_card.collection

    if price_history.present?
      pricing_data = price_history.pricing_data
      price_info = pricing_data[@collection_card.condition] || pricing_data["Raw"]
      @selected_price = price_info["value"] if price_info.present?
    end
  end

  # GET /collection_cards/new
  def new
    @collection_card = CollectionCard.new
  end

  # GET /collection_cards/1/edit
  def edit
  end
  # POST /collection_cards or /collection_cards.json
  def create
    @collections_card = CollectionCard.new(collection_card_params)

    if @collections_card.save
      redirect_to @collections_card, notice: "Card added to collection!"
    else
      redirect_to card_path(@collections_card.card), alert: "Failed to add card to collection."
    end
  end

  # PATCH/PUT /collection_cards/1 or /collection_cards/1.json
  def update
    respond_to do |format|
      if @collection_card.update(collection_card_params)
        format.html { redirect_to @collection_card, notice: "Collection card was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @collection_card }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @collection_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collection_cards/1 or /collection_cards/1.json
  def destroy
    @collection_card.destroy!

    respond_to do |format|
      format.html { redirect_to root_path, notice: "Collection card was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_card
      @collection_card = CollectionCard.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def collection_card_params
      params.require(:collection_card).permit(:collection_id, :card_id, :description, :condition, :price)
    end
end
