class FeedbacksController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_outfit, only: [:new, :create]
  before_action :set_feedback, only: [:show, :edit, :update, :destroy]

  def new
    @feedback = Feedback.new
    authorize @feedback
    skip_policy_scope
  end

  def show
    @feedback = Feedback.find(params[:id])
    authorize @feedback
    skip_policy_scope
  end

  def edit
    authorize @feedback
  end

  def destroy
    authorize @feedback
  end

  def update
    authorize @feedback
    if @feedback.update(feedback_params)
      redirect_to outfit_path(@outfit), notice: "Feedback updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @feedback = Feedback.new
    @feedback.user = current_user
    @feedback.outfit = @outfit
    authorize @feedback
    skip_policy_scope

    @feedback.assign_attributes(feedback_params)

    if @feedback.save
      redirect_to outfit_path(@outfit), notice: "Feedback created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end

  def set_outfit
    @outfit = Outfit.find(params[:outfit_id])
  end

  private

  def feedback_params
    params.require(:feedback).permit(:score, :comment)
  end
end
