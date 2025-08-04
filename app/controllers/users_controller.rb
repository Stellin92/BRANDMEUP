class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update]

  def users
    @users = User.all
  end

  def inbox
    @user = User.find(params[:id])
    @chats = Chat.where("user_id = ? OR partner_id = ?", current_user.id, current_user.id)
    authorize @user
  end

  def show
    authorize @user
    @chat = Chat.new
    skip_policy_scope
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
      @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:bio, :talent, :avatar_url, :username, :photo, :inbox, values: [])
      .tap do |user_params|
        %i[values].each do |field|
          if user_params[field].is_a?(String)
            user_params[field] = user_params[field].split(',').map(&:strip)
          end
        end
      end
  end
end
