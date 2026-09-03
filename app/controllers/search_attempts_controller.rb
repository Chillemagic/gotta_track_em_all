class SearchAttemptsController < ApplicationController
  layout "background_pattern_dark"

  before_action :authenticate_user!

  def create
    uploaded_image = search_attempt_params[:image]
    @search_attempt = current_user.search_attempts.new(
      search_attempt_params.except(:image)
    )

    unless uploaded_image.present?
      @search_attempt.errors.add(:image, "must be provided")
      return render_search_form
    end

    @search_attempt.image.attach(uploaded_image)

    if @search_attempt.save
      IdentifyCardJob.perform_later(@search_attempt.id)
      redirect_to @search_attempt
    else
      render_search_form
    end
  end

  def show
    @search_attempt = current_user.search_attempts.find(params[:id])
  end

  private

  def search_attempt_params
    params.require(:search_attempt).permit(:image, :holo_type)
  end

  def render_search_form
    @holo_options = [
      "Standard",
      "Holo (The Pokemon artwork is shiny)",
      "Reverse Holo (The part outside the artwork is shiny)"
    ]
    flash.now[:alert] = @search_attempt.errors.full_messages.to_sentence
    render "cards/search", status: :unprocessable_entity
  end
end
