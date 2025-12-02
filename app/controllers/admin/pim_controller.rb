module Admin
  class PimController < ApplicationController
    before_action :authorize_pim

    def index
    end

    private

    def authorize_pim
      if cannot? :view, Pim::Product
        raise AuthorizationError
      end
    end
  end
end
