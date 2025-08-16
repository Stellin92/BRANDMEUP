class Feedback < ApplicationRecord
  belongs_to :user
  belongs_to :outfit

  # validates :score, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true
end
