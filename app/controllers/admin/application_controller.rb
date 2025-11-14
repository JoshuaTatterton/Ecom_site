module Admin
  class ApplicationController < ::ApplicationController
    include UserSession

    before_action :require_sign_in
    before_action :validate_user_account
  end
end
