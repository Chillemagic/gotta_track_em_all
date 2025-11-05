class CollectionCardsController < ApplicationController
  before_action :set_collection_card, only: %i[ show edit update destroy ]

  # GET /collection_cards or /collection_cards.json
  def index
    @collection_cards = CollectionCard.all
  end

  # GET /collection_cards/1 or /collection_cards/1.json
  def show
  end

  # GET /collection_cards/new
  def new
    @collection_card = CollectionCard.new
  end

  # GET /collection_cards/1/edit
  def edit
  end
https://github.com/Chillemagic/gotta_track_em_all/pull/33/conflict?name=app%252Fcontrollers%252Fcollection_cards_controller.rb&ancestor_oid=5eb65c3168bf5389b92ee880d2a388785aa6248f&base_oid=e8cd5d6fe1eb008351c42b466de7aae9dd0c32eb&head_oid=95f4821d01aac5c08be45ce2147d4f1eab1e53c9
  # POST /collection_cards or /collection_cards.json
  def create
    @collection_card = CollectionCard.new(collection_card_params)

    respond_to do |format|
      if @collection_card.save
        format.html { redirect_to @collection_card, notice: "Collection card was successfully created." }
        format.json { render :show, status: :created, location: @collection_card }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @collection_card.errors, status: :unprocessable_entity }
      end
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
      format.html { redirect_to collection_path(@collection_card.collection), notice: "Collection card was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection_card
      @collection_card = CollectionCard.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def collection_card_params
      params.expect(collection_card: [ :collection_id, :card_id ])
    end
end
