module Admin
  class SessionController < ::ApplicationController
    include UserSession

    def create
      user = User.find_by(email: sign_in_params[:email])
      if user&.authenticate(sign_in_params[:password])
        sign_in(user)

        redirect_to sign_in_redirect
      else
        redirect_to admin_index_path
      end
    end

    def destroy
      sign_out!

      redirect_to admin_index_path
    end

    private

    def sign_in_params
      params.expect(user: [ :email, :password ])
    end
  end
end
