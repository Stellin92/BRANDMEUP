class OutfitsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_outfit, only: [:show, :edit, :update]

  def new
    @outfit = Outfit.new
    authorize @outfit
    skip_policy_scope
  end

    def show
    authorize @outfit
    skip_policy_scope
  end

  def edit
    authorize @outfit
  end

  def destroy
    authorize @outfit
  end

  def update
    authorize @outfit
    if @outfit.update(outfit_params)
      redirect_to outfit_path(@outfit), notice: "Profile updated!"
    else
      render :edit, status: :unprocessable_entity
    end
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

  def set_outfit
    @outfit = Outfit.find(params[:id])
  end

  private

  def outfit_params
    params.require(:outfit).permit(:title, :description, :style, :color_set, :goal, :outfit_image_url, :items)
  end
end
