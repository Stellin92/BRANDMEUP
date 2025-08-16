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
  @feedback = @outfit.feedbacks.build(feedback_params.merge(user: current_user))

  authorize @feedback

  if @feedback.save
    list_id = view_context.dom_id(@outfit, :feedbacks)
    form_id = view_context.dom_id(@outfit, :new_feedback)

    render turbo_stream: [
      turbo_stream.append(
        list_id,
        partial: "feedbacks/feedback",
        locals: { feedback: @feedback }
      ),
      turbo_stream.replace(
        form_id,
        partial: "feedbacks/form",
        locals: { outfit: @outfit, feedback: Feedback.new }
      )
    ]
  else
    form_id = view_context.dom_id(@outfit, :new_feedback)
    render turbo_stream: turbo_stream.replace(
      form_id,
      partial: "feedbacks/form",
      locals: { outfit: @outfit, feedback: @feedback }
    )
  end
end

  def set_feedback
    @feedback = Feedback.find(params[:id])
  end


  private

   def set_outfit
    @outfit = Outfit.find(params[:outfit_id])
  end
  def feedback_params
    params.require(:feedback).permit(:score, :comment)
  end
end
