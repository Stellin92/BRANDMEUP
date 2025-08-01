class OutfitsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :authorize_user!, only: [:edit, :update]

  def new
    @outfit = Outfit.new
    authorize @outfit
    skip_policy_scope
  end

  def create
    @outfit = Outfit.new
    authorize @outfit
    skip_policy_scope

    @outfit.assign_attributes(outfit_params)

    @outfit.user = current_user
    if @outfit.save
      redirect_to outfit_path(@outfit), notice: "Outfit created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

   def set_user
    @user = current_user
  end

  def show
    authorize @outfit
    skip_policy_scope
    @outfit = Outfit.find[params[:id]]
  end

  def edit
    authorize @outfit
  end

  def destroy
    authorize @outfit
  end

  def update
    authorize @outfit
    @post = Post.find(params[:id])
    if @post.update(outfit_params)
      redirect_to @post
    else
      render :edit
    end
  end

  private

  def outfit_params
    attrs = action_name == "create" ? policy(@outfit).permitted_attributes_for_create : policy(@outfit).permitted_attributes_for_update
    params.require(:outfit).permit(attrs)
  end
end
