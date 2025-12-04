class JobPolicy < ApplicationPolicy
  def show?
    owner_or_admin?
  end

  def create?
    user.present?
  end

  def update?
    owner_or_admin?
  end

  def destroy?
    owner_or_admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def owner_or_admin?
    user.present? && (record.user_id == user.id || user.admin?)
  end
end
