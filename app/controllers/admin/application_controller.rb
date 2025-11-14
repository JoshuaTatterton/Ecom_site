module Admin
  class ApplicationController < ::ApplicationController
    include UserSession

    before_action :require_sign_in
  end
end
