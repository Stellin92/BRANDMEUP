class MessagesController < ApplicationController
  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.user = current_user
    authorize @message

    puts params.inspect

    if @message.save
      redirect_to user_chat_path(current_user, @chat), notice: "Message sent"
    else
      redirect_to inbox_user_path(user)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
