module Admin
  class UsersController < ApplicationController
    include Pagination

    helper_method :memberships, :user

    def index
      authorize :view, Membership
    end

    # def new
    #   authorize :create, Role
    # end

    # def create
    #   @role = Role.new(role_params)
    #   authorize :create, @role

    #   @role.permissions = PermissionsHelper.serialized_form_permissions(permissions_params)
    #   if @role.save
    #     redirect_to action: :index
    #   else
    #     render :new
    #   end
    # end

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

    # def user_params
    #   # SecureRandom.uuid
    #   params.require(:user).permit(:email)
    # end

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

    # def user
    #   @user ||= User.new
    # end
  end
end
