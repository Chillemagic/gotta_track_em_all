class CollectionCardsController < ApplicationController
  before_action :set_collection_card, only: %i[ show edit update destroy ]

  layout "background_pattern_dark"

  # GET /collection_cards or /collection_cards.json
  def index
    @collection_cards = CollectionCard.all
  end

  # GET /collection_cards/1 or /collection_cards/1.json
  def show
    @collection = @collection_card.collection
    @selected_price = @collection_card.fetch_price
  end

  # GET /collection_cards/new
  def new
    @collection_card = CollectionCard.new
  end

  # GET /collection_cards/1/edit
  def edit
  end
  # POST /collection_cards or /collection_cards.json
  # def create
  #   @user = current_user
  #   @search_attempt = SearchAttempt.find(params[:search_attempt_id])
  #   # Check if current_user belongs to the search_attempt.
  #   if @user.search_attempts.find(@search_attempt.id)
  #     @collection_card = CollectionCard.new(collection_card_params)
  #   else
  #     redirect_to search_cards_path, alert: "Search again, this attempt does not belong to the current user"
  #   end
  #
  #   if @collection_card.save
  #     redirect_to @collection_card, notice: "Card added to collection!"
  #   else
  #     redirect_to card_path(@collection_card.card), alert: "Failed to add card to collection."
  #   end
  # end

  def create
    @search_attempt = current_user.search_attempts.find(params[:search_attempt_id])
    collection = current_user.collections.find(collection_card_params[:collection_id])

    @collection_card = collection.collection_cards.new(
      collection_card_params.except(:collection_id, :card_id)
    )
    @collection_card.card = @search_attempt.card

    if @collection_card.save
      redirect_to @collection_card, notice: "Card added to collection!"
    else
      redirect_to search_attempt_path(@search_attempt),
                  alert: "Failed to add card to collection."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to search_cards_path,
                alert: "Search again. The search attempt or collection is invalid."
  end

  # PATCH/PUT /collection_cards/1 or /collection_cards/1.json
  def update
    respond_to do |format|
      if @collection_card.update(collection_card_params)
        format.html { redirect_to @collection_card, notice: "Collection card updated.", status: :see_other }
        format.json { render json: @collection_card }
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
      params.require(:collection_card).permit(:collection_id, :card_id, :description, :condition, :price, :favourite, :search_attempt_id)
    end
end
