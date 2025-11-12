module Admin
  class RolesController < ApplicationController
    include Pagination

    helper_method :roles, :role

    def index
    end

    def new
    end

    def create
      @role = Role.new(role_params)
      PermissionsHelper.add_sanitized_form_permissions(@role, permissions_params)
      if @role.save
        redirect_to action: :index
      else
        render :new
      end
    end

    def edit
      @role = Role.find(params[:id])
    end

    def update
      @role = Role.find(params[:id])
      PermissionsHelper.add_sanitized_form_permissions(@role, permissions_params)
      if role.update(role_params)
        redirect_to action: :index
      else
        render :edit
      end
    end

    def destroy
      @role = Role.find(params[:id])
      role.destroy

      redirect_to action: :index
    end

    private

    def role_params
      params.require(:role).permit(:name)
    end

    def permissions_params
      # Default to {} incase all permissions are false so would be empty
      params.require(:role)[:permissions]&.permit! || {}
    end

    def roles
      @roles ||= base_scope.offset(page_offset).limit(page_limit)
    end

    def base_scope
      Role.order(id: :desc)
    end

    def role
      @role ||= Role.new
    end
  end
end
