class CollectionsController < ApplicationController
  layout :choose_layout

  before_action :authenticate_user! # for Devise
  before_action :set_collection, only: %i[show edit update destroy]

  def index
    @collections = current_user.collections.order(created_at: :desc) # newest collection first
  end

  # GET /collections/:id
  def show
    @collection_cards = @collection.collection_cards.includes(:card)
  end

  def new
    @collection = current_user.collections.new
  end

  def create
    @collection = current_user.collections.new(collection_params)
    @card = Card.find_by(id: params.dig(:collection, :card_id))
    # get card so Turbo Stream can render dropdown

    if @collection.save
      respond_to do |format|
        if turbo_frame_request?
          @collection_card = CollectionCard.new
          format.html { render partial: "cards/collection_frame", locals: { collection: @collection } }
        else
          format.html { redirect_to collections_path, notice: "Collection created!" }
        end
      end
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
    # Check if user has more than one collection
    user = @collection.user
    if user.collections.count <= 1
      redirect_to collections_path,
        alert: "You must have at least one Collection"
      return
    end

    @collection.destroy
    redirect_to collections_path, notice: "Collection deleted"
  end

  private

  def set_collection
    @collection = current_user.collections.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(:name, :description, card_ids: [])
  end

  def choose_layout
    case action_name.to_sym
    when :show, :index
      "background_pattern_dark"
    when :edit, :new
      "background_nature"
    else
      "application"
    end
  end
end
