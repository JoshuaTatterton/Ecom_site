module Admin
  class UsersController < ApplicationController
    include Pagination

    helper_method :memberships, :membership, :user, :role, :roles_scope

    def index
      authorize :view, Membership
    end

    def new
      authorize :add, Membership
    end

    def create
      @role = Role.find(role_id)
      @user = User.find_or_initialize_by(email: user_email)
      @membership = @role.memberships.new(user: @user)

      authorize :add, @membership

      if @membership.save
        UserSignUpJob.perform_async(@membership.id) if @user.previously_new_record?

        redirect_to action: :index
      else
        render :new
      end
    end

    def edit
      @membership = Membership.find(params[:id])

      authorize :update, @membership
    end

    def update
      @membership = Membership.find(params[:id])

      authorize :update, @membership

      @role = Role.find(role_id)
      @membership.role = @role

      authorize :update, @membership

      if @membership.save
        redirect_to action: :index
      else
        render :edit
      end
    end

    def destroy
      @membership = Membership.find(params[:id])

      authorize :remove, @membership

      @membership.destroy

      redirect_to action: :index
    end

    private

    def user_email
      params.require(:user).permit(:email).fetch(:email)
    end

    def role_id
      params.require(:user).permit(:role).fetch(:role)
    end

    def memberships
      @memberships ||= base_scope.includes(:user, :role).offset(page_offset).limit(page_limit)
    end

    def base_scope
      Membership.order(id: :desc)
    end

    def membership
      @membership ||= Membership.new
    end

    def user
      @user ||= User.new
    end

    def role
      @role ||= Role.new
    end

    def roles_scope
      admin_user? ? Role.order(:name) : Role.where(administrator: false).order(:name)
    end
  end
end
