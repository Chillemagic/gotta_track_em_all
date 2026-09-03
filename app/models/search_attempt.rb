class SearchAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :card, optional: true

  has_one_attached :image

  enum :status, {
    pending: "pending",
    identifying: "identifying",
    matched: "matched",
    creating_card: "creating_card",
    failed: "failed"
  }, prefix: true

  enum :scrydex_status, {
    not_requested: "not_requested",
    queued: "queued",
    processing: "processing",
    succeeded: "succeeded",
    failed: "failed"
  }, prefix: true

  after_update_commit :broadcast_result

  private

  def broadcast_result
    broadcast_replace_to(
      self,
      target: ActionView::RecordIdentifier.dom_id(self),
      partial: "search_attempts/result",
      locals: { search_attempt: self }
    )
  end
end
