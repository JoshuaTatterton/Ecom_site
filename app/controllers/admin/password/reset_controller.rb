module Admin
  module Password
    class ResetController < ::ApplicationController
      include UserSession

      before_action :validate_signed_out

      def index
      end

      def create
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
