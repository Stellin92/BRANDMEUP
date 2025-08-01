class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def users
    @users = User.all
  end

  def set_user
    @user = current_user
  end

  def show
    authorize @user
    skip_policy_scope
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    @post = Post.find(params[:id])
    if @post.update(post_params)
      redirect_to @post
    else
      render :edit
    end
  end

  private

  def post_params
    params.require(:post).permit(policy(@post).permitted_attributes)
  end
end
