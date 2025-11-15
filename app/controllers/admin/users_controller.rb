module Admin
  class UsersController < ApplicationController
    include Pagination

    helper_method :memberships, :user, :role, :roles_scope

    def index
      authorize :view, Membership
    end

    def new
      authorize :add, Membership
    end

    def create
      @role = Role.find(user_params[:role])
      @user = User.find_or_initialize_by(email: user_params[:email])
      @membership = @role.memberships.new(user: @user)

      authorize :add, @membership

      if @membership.save
        redirect_to action: :index
      else
        render :new
      end
    end

    # def edit
    #   @role = Role.find(params[:id])
    #   authorize :update, @role
    # end

    # def update
    #   @role = Role.find(params[:id])
    #   authorize :update, @role

    #   @role.permissions = PermissionsHelper.serialized_form_permissions(permissions_params)
    #   if role.update(role_params)
    #     redirect_to action: :index
    #   else
    #     render :edit
    #   end
    # end

    # def destroy
    #   @role = Role.find(params[:id])
    #   authorize :delete, @role

    #   role.destroy

    #   redirect_to action: :index
    # end

    private

    def user_params
      # SecureRandom.uuid
      @user_params ||= params.require(:user).permit(:email, :role)
    end

    # def permissions_params
    #   # Default to {} incase all permissions are false so would be empty
    #   parameters = params.require(:role).permit(permissions: PermissionsHelper.permitted_params) || {}
    #   parameters.fetch(:permissions, {})
    # end

    def memberships
      @memberships ||= base_scope.includes(:user, :role).offset(page_offset).limit(page_limit)
    end

    def base_scope
      Membership.order(id: :desc)
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
