class MessagePolicy < ApplicationPolicy
  # record: Message

  def create?
    user.present? &&
      record.user_id == user.id &&          # l’auteur du message = user courant
      record.chat.involves?(user)           # et il fait partie du chat
  end

  # (Pas de Scope nécessaire ici, on ne liste pas des messages seuls)
end
