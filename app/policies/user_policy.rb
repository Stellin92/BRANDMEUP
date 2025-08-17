class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # Tous les profils sont visibles
      scope.all
    end
  end

  # --- Lecture ---
  def show?
    true
  end

  # --- Edition / Mise à jour ---
  def edit?
    user_is_self? || admin?
  end

  def update?
    user_is_self? || admin?
  end

  # --- Inbox (doit être accessible uniquement par l'utilisateur lui-même) ---
  def inbox?
    user_is_self? || admin?
  end

  # --- Strong params via Pundit ---
  def permitted_attributes
    base = [:bio, :talent, :avatar_url, :username, :photo, { values: [] }]
    if user_is_self? || admin?
      base
    else
      [] # personne d'autre ne peut modifier le profil
    end
  end

  private

  def user_is_self?
    user.present? && record.is_a?(User) && user.id == record.id
  end

  def admin?
    user.respond_to?(:admin?) && user.admin?
  end
end
