module Admin
  class AuthController < ApplicationController
    before_action :authorize_auth

    def index
    end

    private

    def authorize_auth
      if cannot?(:view, Role) && cannot?(:view, Membership)
        raise AuthorizationError
      end
    end
  end
end
