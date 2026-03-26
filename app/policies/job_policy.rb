class JobPolicy < ApplicationPolicy
  def show?
    owns_record?
  end

  def create?
    user.present?
  end

  def update?
    owns_record?
  end

  def destroy?
    owns_record?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
        scope.where(user_id: user.id)   
    end
  end

  private

  def owns_record?
    user.present? && record.user_id == user.id 
  end
end
