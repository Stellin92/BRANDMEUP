class PagesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def guide
  end

  def outfit
  end

  def discovery
    @users = User.order(created_at: :desc).limit(30)
  end

end
