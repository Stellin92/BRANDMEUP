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
    else
      render :show
    end

    respond_to do |format|
    format.html
    format.pdf do
      html = render_to_string(
        template: "outfits/pdf",
        layout:   "pdf",
        formats:  [:html]
      )

      options = {
        format: "A4",
        preferCSSPageSize: true,
        print_background: true,
        margin: { top: "12mm", right: "12mm", bottom: "12mm", left: "12mm" },
        display_header_footer: true,
        footer_template: <<~HTML
          <div style="font-size:10px;width:100%;text-align:right;padding-right:12mm;">
            Page <span class="pageNumber"></span> / <span class="totalPages"></span>
          </div>
        HTML
        ,
        # Ces flags sont importants sur Heroku
        launch_args: ["--no-sandbox", "--disable-setuid-sandbox", "--disable-dev-shm-usage"],
        wait_until: "networkidle0" # attend que les images/feuilles soient chargées
      }

      pdf = Grover.new(html, options).to_pdf

      send_data pdf,
        filename: "outfit_#{@outfit.id}.pdf",
        type: "application/pdf",
        disposition: "attachment"
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
      redirect_to outfit_path(@outfit), notice: "Outfit created successfully."
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
