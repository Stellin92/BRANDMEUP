class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def guide
  end

  def outfit
  end

  def discovery
    # ---- simple grid (tout d'un coup) ----
    # @users = User.order(created_at: :desc).limit(60)

    # ---- version "Load more" avec Turbo (recommandé) ----
    per_page = 12
    @page    = params.fetch(:page, 1).to_i
    @users   = User.order(created_at: :desc)
                   .offset((@page - 1) * per_page)
                   .limit(per_page)
    @total   = User.count

    respond_to do |format|
      format.html # page complète
      format.turbo_stream # ne renvoie que le frame de la grid
    end
  end

end
