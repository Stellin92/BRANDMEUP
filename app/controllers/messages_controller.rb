class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    chat =
      if params[:chat_id].present?
        # Route nestée: /users/:user_id/chats/:chat_id/messages
        policy_scope(Chat).find(params[:chat_id]).tap { |c| authorize c, :show? }
      else
        # Premier message: POST /messages  (depuis le mini-form du profil)
        receiver = User.find(params.require(:receiver_id))
        Chat.between(current_user, receiver) ||
          Chat.new(user: current_user, partner: receiver).tap { |c| authorize c, :create?; c.save! }
      end

    message = chat.messages.build(user: current_user, content: params.require(:content))
    authorize message

    if message.save
      @chat     = chat
      @messages = chat.messages.includes(:user).order(:created_at)
      render "chats/show", layout: false, status: :ok
    else
      render plain: message.errors.full_messages.to_sentence, status: :unprocessable_entity
    end
  end
end
