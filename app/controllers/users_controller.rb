class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update, :inbox]
  after_action :verify_policy_scoped, only: :inbox

  def inbox
    authorize @user, :inbox?
    @chats = policy_scope(Chat).includes(:user, :partner).recent_first
    render "chats/index", layout: false
  end

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(permitted_user_params)
      redirect_to user_path(@user), notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    if params[:id].to_s !~ /\A\d+\z/
      redirect_to root_path, alert: "Invalid user" and return
    end
    @user = User.find(params[:id])
  end

  def permitted_user_params
    params.require(:user).permit(policy(@user).permitted_attributes)
  end
end
