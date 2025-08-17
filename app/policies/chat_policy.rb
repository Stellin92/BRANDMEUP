class ChatPolicy < ApplicationPolicy
  # record: Chat

  def index?
    user.present?
  end

  def show?
    record.involves?(user)
  end

  def create?
    user.present? &&
      record.user_id == user.id &&          # l’initiateur doit être l’utilisateur courant
      record.partner_id.present? &&
      record.partner_id != user.id          # pas de chat avec soi-même
  end

  def destroy?
    show?                                   # un participant peut supprimer la conversation
  end

  class Scope < Scope
    # Liste uniquement les chats où l’utilisateur est impliqué
    def resolve
      return scope.none unless user
      scope.where("user_id = :id OR partner_id = :id", id: user.id)
    end
  end
end
