class Ability
  include CanCan::Ability

  def initialize(user)
    # alias_action :create, :read, :update, :destroy, :to => :crud
    # if user
    #     if user.role == "manager"
    #         can :crud, Business, :id => user.business_id 
    #         # this will cek whether user can access business instance (id)     
    #     elsif user.role == "owner"
    #         can :manage, :all
    #     end
    # end
  end
end
