class SearchAttemptsController < ApplicationController
  layout "background_pattern_dark"

  before_action :authenticate_user!
  before_action :set_search_attempt

  # Redirects after making a search_attempt. Will redirect to @Collection_Card when found
  def show
  end

  def retry_with_scrydex
    claimed = current_user.search_attempts
      .where(id: @search_attempt.id, scrydex_requested_at: nil)
      .update_all(
        scrydex_requested_at: Time.current,
        provider: "scrydex",
        status: "identifying",
        error_message: nil,
        updated_at: Time.current
      )

    if claimed == 1
      ScrydexIdentificationJob.perform_later(@search_attempt.id, current_user.id)
      redirect_to @search_attempt
    else
      redirect_to @search_attempt,
        alert: "A premium search has already been requested."
    end
  end

  private

  def set_search_attempt
    @search_attempt = current_user.search_attempts.find(params[:id])
  end
end
