class ChatsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_chat, only: [:show, :destroy]

  def create
    @partner = User.find(params[:partner_id])

    existing_chat = Chat.find_by(
      user: current_user, partner: @partner
    ) || Chat.find_by(
      user: @partner, partner: current_user
    )

    if existing_chat
      authorize existing_chat, :show?
      redirect_to user_chat_path(current_user, existing_chat), notice: "There is already a chat created with #{@partner.username}"
      return
    end

    @chat = Chat.new(user: current_user, partner: @partner)
    # @chat.partner = @partner
    # @chat.user = current_user

    authorize @chat
    if @chat.save
      redirect_to user_chat_path(current_user, @chat)
    else
      redirect_to user_path(@partner)
    end
  end

  def show
    @chat = Chat.find(params[:id])
    @message = Message.new
    authorize @chat
  end

  def destroy
    authorize @chat
    @chat.destroy
    redirect_to inbox_user_path(current_user), notice: "Chat deleted"
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(date)
  end
end
