class SearchAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :card, optional: true

  has_one_attached :image

  after_update_commit -> {
    Rails.logger.info "🔔 Broadcasting update for search_attempt#{id}"

    broadcast_replace_to(
      "search_attempt_#{id}",
      target: "search_attempt_#{id}",
      partial: "search_attempts/search_attempt_info",
      locals: { search_attempt: self }
    )
  }

  enum :status, {
    pending: "pending",
    identifying: "identifying",
    matched: "matched",
    creating_card: "creating_card",
    failed: "failed"
  }, prefix: true

  def broadcast_pricing
    broadcast_replace_to(
      "search_attempt_#{id}",
      target: ActionView::RecordIdentifier.dom_id(self, :pricing),
      partial: "cards/pricing",
      locals: { card: card, search_attempt: self }
    )

    broadcast_replace_to(
      "search_attempt_#{id}",
      target: ActionView::RecordIdentifier.dom_id(self, :condition_select),
      partial: "search_attempts/condition_select",
      locals: { card: card, search_attempt: self }
    )
  end
end
