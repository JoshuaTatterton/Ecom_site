module Admin
  class UserEditController < ::ApplicationController
    include UserSession

    before_action :require_sign_in

    helper_method :user

    def index
    end

    def create
      if user.update(user_params)
        redirect_to admin_index_path
      else
        render :index
      end
    end

    private

    def user
      @user ||= current_user
    end

    def user_params
      params.require(:user).permit(:name)
    end
  end
end
