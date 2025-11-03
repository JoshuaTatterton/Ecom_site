class Ability
  include CanCan::Ability

  # Temporarily accepts a role to test, with eventually accept a user
  def initialize(role)
    if role.administrator
      can :manage, :all
    else
      role.permissions.each do |permission|
        can permission["action"].to_sym, permission["resource"].to_sym
      end
    end
  end
end
