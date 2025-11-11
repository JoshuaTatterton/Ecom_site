module Admin
  class RolesController < ApplicationController
    helper_method :roles

    def index
    end

    private

    def roles
      @roles ||= Role.order(id: :desc)
    end
  end
end
