class UsersController < ApplicationController
  before_action :authenticate_user!, except [:show, :index]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def users
    @users = User.all
  end

  def show
    authorize @user
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
  end
end
