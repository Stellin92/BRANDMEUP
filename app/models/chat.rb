class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: "User"
  has_many :messages, dependent: :destroy

  scope :for_user, ->(u) { where("user_id = :id OR partner_id = :id", id: u.id) }
  scope :recent_first, -> { order(updated_at: :desc) }

  def involves?(u)
    user_id == u.id || partner_id == u.id
  end

  def other_user(u)
    u.id == user_id ? partner : user
  end

  def self.between(a, b)
    key = [a.id, b.id].minmax.join(":")
    find_by(key: key)
  end

  before_validation :set_key
  validates :key, presence: true, uniqueness: true
  validate :distinct_participants

  private

  def set_key
    return unless user_id && partner_id
    self.key = [user_id, partner_id].minmax.join(":")
  end

  def distinct_participants
    errors.add(:base, "Participants must be different") if user_id == partner_id
  end
end
