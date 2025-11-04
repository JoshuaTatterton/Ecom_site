class Ability
  include CanCan::Ability

  def initialize(user)
    if user.role.administrator
      can :manage, :all
    else
      user.role.permissions.each do |permission|
        can permission["action"].to_sym, permission["resource"].to_sym
      end
    end
  end
end
