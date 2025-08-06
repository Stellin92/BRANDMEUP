class Outfit < ApplicationRecord
  belongs_to :user
  has_many :feedbacks, dependent: :destroy

  has_one_attached :photo

  def has_feedback?
    result = self.feedbacks.length > 0 ? true : false
  end
end
