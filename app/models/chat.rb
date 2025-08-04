class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :partner, class_name: 'User'
  has_many :messages, dependent: :destroy

  def has_message?
    result = self.messages.length > 0 ? true : false
  end
end
