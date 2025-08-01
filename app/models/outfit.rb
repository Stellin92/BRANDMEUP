class Outfit < ApplicationRecord
  has_many :feedbacks
  belongs_to :user
end
