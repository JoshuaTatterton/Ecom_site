class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role.administrator
      can :manage, :all
    else
      apply_user_role_permissions(user.role)

      apply_user_cans(user)
    end

    apply_global_cannots(user)
  end

  def apply_user_role_permissions(role)
    role.permissions.each do |permission|
      resource = permission["resource"]

      # Apply a generic can with symbols incase of some edge case
      # permissions not using active record models
      can permission["action"].to_sym, resource.to_sym

      # Apply active record model based permissions if available
      resource_klass = PermissionsHelper::RESOURCE_MAP[resource]
      can permission["action"].to_sym, resource_klass if resource_klass
    end
  end

  def apply_user_cans(user)
    # User can update themselves
    can "update", user
  end

  def apply_global_cannots(user)
    # Cannot update their own role
    cannot "update", user.role
    # Cannot change their own role
    cannot "update", user.membership
    # Cannot remove themselves from an account
    cannot "delete", user.membership
  end
end
