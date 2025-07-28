class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
  end

  def register
  end

  def guide
  end

  def outfit
  end

  def validation
  end

end
