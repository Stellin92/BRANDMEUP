class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :chat, touch: true

  validates :content, presence: true

  after_create_commit do
    broadcast_append_to chat,
      target: dom_id(chat, :messages),
      partial: "messages/message",
      locals: { message: self }
  end
end
