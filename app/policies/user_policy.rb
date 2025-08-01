class UserPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def permitted_attributes
    if user.admin? || user.owner_of?(post)
      [:talent, :bio, :avatar_url, :values]
    else
      [:tag_list]
    end
  end

  # def permitted_attributes_for_edit
  #   [:talent, :bio, :avatar_url, :values]
  # end

  # def permitted_attributes_for_update
  #   [:talent, :bio, :avatar_url, :values]
  # end

  def show?
    true
  end

  def edit?
    user == record
  end

  def update?
    user == record
  end
end
