class CollectionsController < ApplicationController

  before_action :authenticate_user! # for Devise
  before_action :set_collection, only: [:show, :edit, :update, :destroy]

  def index
    @collections = current_user.collections.order(created_at: :desc) # newest collection first
  end

  def show
    #@collection = current_user.collections.find(params[:id])
  end

  def new
    @collection = current_user.collections.new
  end

  def create
    @collection = current_user.collections.new(collection_params)
    if @collection.save
      redirect_to @collection, notice: "Collection created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
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
