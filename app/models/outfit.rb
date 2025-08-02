class Outfit < ApplicationRecord
  belongs_to :user
  has_many :feedbacks, dependent: :destroy
end
