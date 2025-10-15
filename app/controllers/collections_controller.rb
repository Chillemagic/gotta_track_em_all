class CollectionsController < ApplicationController
  before_action :authenticate_user! # for Devise

  def index
    @collections = current_user.collections.order(created_at: :desc) # newest collection first
  end

  def show
    @collection = current_user.collections.find(params[:id])
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

  private
  def collection_params
    params.require(:collection).permit(:name, :description)
  end
end
