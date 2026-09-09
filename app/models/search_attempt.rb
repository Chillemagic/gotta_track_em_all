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
end
