module Admin
  module Password
    class ResetController < ::ApplicationController
      include UserSession

      before_action :validate_signed_out

      def index
        @user = User.find_by_password_reset_token(token_param)
        if @user
          session[:reset_user_id] = @user.id

          render
        else
          session.delete(:reset_user_id)

          redirect_to admin_index_path
        end
      end

      def create
        @user = User.find_by(id: session[:reset_user_id])

        if !@user
          session.delete(:reset_user_id)

          redirect_to admin_index_path
        elsif @user.update(awaiting_authentication: false, **user_params)
          sign_in(@user)
          session.delete(:reset_user_id)

          redirect_to sign_in_redirect
        else
          render :index
        end
      end

      private

      def token_param
        params.permit(:token).fetch(:token)
      end

      def user_params
        params.require(:user).permit(:password, :password_confirmation)
      end

      def validate_signed_out
        if signed_in?
          redirect_to admin_index_path
        end
      end
    end
  end
end
