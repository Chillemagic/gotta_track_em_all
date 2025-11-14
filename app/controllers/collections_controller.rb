class CollectionsController < ApplicationController
  layout "background_pattern_dark", only: %i[show index new] # for pokemondark background, white text
  # layout "background_nature", only: [:edit]

  before_action :authenticate_user! # for Devise
  before_action :set_collection, only: %i[show edit update destroy]

  def index
    @collections = current_user.collections.order(created_at: :desc) # newest collection first
  end

  # GET /collections/:id
  def show
    @collection = Collection.find(params[:id])
    @collection_cards = @collection.collection_cards.includes(:card)
  end

  def new
    @collection = current_user.collections.new
  end

  def create
    @collection = current_user.collections.new(collection_params)

    if @collection.save
      redirect_to collections_path, notice: "Collection created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render layout: "background_nature"
    @cards = Card.all # Loads all Card records so the edit form can show checkboxes
  end

  def update
    if @collection.update(collection_params)
      redirect_to collections_path, notice: "Collection updated!"
    else
      @cards = Card.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path
  end

  private

  def set_collection
    @collection = current_user.collections.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :description, card_ids: [])
  end
end
