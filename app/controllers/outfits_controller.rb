class OutfitsController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_outfit, only: [:show, :edit, :update, :destroy]

  def outfits
    @outfit = Outfit.all
  end

  def new
    @outfit = Outfit.new
    authorize @outfit
    skip_policy_scope
  end

    def show
      authorize @outfit
      if params[:modal].present?
        render partial: "outfits/modal", locals: { outfit: @outfit }
        return
      end

      respond_to do |format|
        format.html { render :show }

        format.pdf do
          render pdf: "outfit_#{@outfit.id}",
                template: "outfits/pdf",   # => app/views/outfits/pdf.html.erb
                formats:  [:html],          # <= clé : on force Rails à prendre la vue HTML
                handlers: [:erb],           # <= (optionnel) précise le moteur si besoin
                layout:   "pdf",            # => app/views/layouts/pdf.html.erb
                encoding: "UTF-8",

                # options wkhtmltopdf ok
                disable_smart_shrinking: false,
                zoom: 1.0,
                viewport_size: "1280x1024",
                print_media_type: true,
                background: true,

                page_size: "A4",
                margin: { top: 12, bottom: 12, left: 12, right: 12 },
                footer: { right: "Page [page] / [toPage]" }
        end
      end

      skip_policy_scope
    end

  def edit
    authorize @outfit
  end

  def destroy
    @outfit.destroy
    authorize @outfit
    respond_to do |format|
      format.html { redirect_to user_path(@outfit.user), notice: "Outfit was successfully deleted." }
      format.turbo_stream
    end
  end

  def update
    authorize @outfit
    if @outfit.update(outfit_params)
      redirect_to user_path(@outfit.user), notice: "Profile updated!"
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
      redirect_to user_path(@outfit.user), notice: "Outfit created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_outfit
    @outfit = Outfit.find(params[:id])
  end

  def outfit_params
    params.require(:outfit).permit(:title, :description, :style, :goal, :photo, items_list: [], color_set: [])
          .tap do |outfit_params|
            %i[color_set items_list].each do |field|
              if outfit_params[field].is_a?(String)
                outfit_params[field] = outfit_params[field].split(',').map(&:strip)
              end
            end
        end
  end
end
