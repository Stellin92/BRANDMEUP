class ChatsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_policy_scoped, only: :index

  def index
    @chats = policy_scope(Chat).includes(:user, :partner).recent_first
    render layout: false
  end

  def show
    @chat = policy_scope(Chat).find(params[:id])
    authorize @chat
    @messages = @chat.messages.includes(:user).order(:created_at)
    render layout: false
  end

  def index
    @chats = policy_scope(Chat).includes(:user, :partner).recent_first
    render layout: false
  end

  def show
    @chat = policy_scope(Chat).find(params[:id])
    authorize @chat
    @messages = @chat.messages.includes(:user).order(:created_at)
    render layout: false
  end

  def create
    partner = User.find(params.require(:partner_id))
    @chat = Chat.between(current_user, partner) || Chat.new(user: current_user, partner: partner)
    authorize @chat, :create?
    @chat.save! unless @chat.persisted?
    redirect_to user_chat_path(current_user, @chat)
  end

  def destroy
    @chat = policy_scope(Chat).find(params[:id])
    authorize @chat
    @chat.destroy!
    head :no_content
  end

end
