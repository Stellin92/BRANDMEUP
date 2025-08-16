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

    if @feedback.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            # ajoute uniquement le nouveau feedback
            turbo_stream.append(
              dom_id(@outfit, :feedbacks),
              partial: "feedbacks/feedback",
              locals: { feedback: @feedback }
            ),
            # réinitialise le formulaire
            turbo_stream.replace(
              dom_id(@outfit, :new_feedback),
              partial: "feedbacks/form",
              locals: { outfit: @outfit, feedback: Feedback.new }
            )
          ]
        end
        format.html { redirect_to outfit_path(@outfit) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@outfit, :new_feedback),
            partial: "feedbacks/form",
            locals: { outfit: @outfit, feedback: @feedback }
          )
        end
        format.html { render "outfits/show", status: :unprocessable_entity }
      end
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
