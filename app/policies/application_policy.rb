class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user      # l'utilisateur connecté (current_user)
    @record = record  # le modèle qu'on autorise (ex: un User, un Post, etc.)
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
