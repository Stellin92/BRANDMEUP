class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?

  skip_after_action :verify_authorized, only: :index, raise: false

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,        keys: [:talent, :avatar_url, :bio, :values])
    devise_parameter_sanitizer.permit(:account_update, keys: [:talent, :avatar_url, :bio, :values])
  end

  private
  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
