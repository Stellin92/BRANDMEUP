# frozen_string_literal: true
class Users::RegistrationsController < Devise::RegistrationsController
  # Autoriser les params supplémentaires
  before_action :configure_sign_up_params, only: [:create]

  protected

  # Redirection après INSCRIPTION (user actif)
  def after_sign_up_path_for(resource)
    guide_path
  end

  # Redirection si user INACTIF (confirmable, etc.)
  def after_inactive_sign_up_path_for(resource)
    guide_path
  end

  # (Optionnel mais recommandé) Redirection après CONNEXION
  # def after_sign_in_path_for(resource)
  #   guide_path
  # end

  # Strong params pour l'inscription
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
