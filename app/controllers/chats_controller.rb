class ChatsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_chat, only: [:show, :destroy]

  def create
    @partner = User.find(params[:partner_id])
    @chat = Chat.new
    @chat.partner = @partner
    @chat.user = current_user
    authorize @chat
    if @chat.save
      redirect_to user_chat_path(current_user, @chat)
    else
      redirect_to user_path(@partner)
    end
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def show
    authorize @chat
  end

  def destroy
    authorize @chat
  end

  private

  def chat_params
    params.require(:chat).permit(date)
  end
end
