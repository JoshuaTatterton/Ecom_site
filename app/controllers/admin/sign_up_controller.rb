module Admin
  class SignUpController < ::ApplicationController
    include UserSession

    before_action :validate_signed_out

    helper_method :user

    def index
      @user = User.find_by_authentication_password_reset_token(token_param)
      if @user&.awaiting_authentication
        session[:auth_user_id] = @user.id
        render
      else
        redirect_to admin_index_path
      end
    end

    def create
      @user = User.find(session[:auth_user_id])

      if !@user&.awaiting_authentication?
        session.delete(:auth_user_id)

        redirect_to admin_index_path
      elsif @user.update(awaiting_authentication: false, **user_params)
        sign_in(user)
        session.delete(:auth_user_id)

        redirect_to sign_in_redirect
      else
        render :index
      end
    end

    private

    def user
      @user
    end

    def token_param
      params.permit(:token).fetch(:token)
    end

    def user_params
      params.require(:user).permit(:name, :password, :password_confirmation)
    end

    def validate_signed_out
      if signed_in?
        redirect_to admin_index_path
      end
    end
  end
end
