module Admin
  module Password
    class RecoveryController < ::ApplicationController
      include UserSession

      before_action :validate_signed_out

      def index
      end

      def create
        user = User.find_by(email: user_param)

        if user&.awaiting_authentication? && user&.user_memberships&.any?
          Switch.account(user.user_memberships.first.account_reference) {
            UserSignUpJob.perform_async(user.id)
          }
        elsif user&.awaiting_authentication?
          UserSignUpJob.perform_async(user.id)
        elsif user
          PasswordRecoveryJob.perform_async(user.id)
        end

        redirect_to admin_index_path
      end

      private

      def user_param
        params.require(:user).permit(:email).fetch(:email)
      end

      def validate_signed_out
        if signed_in?
          redirect_to admin_index_path
        end
      end
    end
  end
end
