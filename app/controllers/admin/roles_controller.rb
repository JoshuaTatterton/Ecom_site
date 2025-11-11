module Admin
  class RolesController < ApplicationController
    helper_method :roles, :role

    def index
    end

    def new
    end

    def create
      @role = Role.new(role_params)
      if role.save
        redirect_to action: :index
      else
        render :new
      end
    end

    private

    def role_params
      params.expect(role: [ :name ])
    end

    def roles
      @roles ||= Role.order(id: :desc)
    end

    def role
      @role ||= Role.new
    end
  end
end
