module Admin
  class ApplicationController < ::ApplicationController
    include UserSession

    helper_method :current_user
  end
end
