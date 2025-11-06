class AdminController < ApplicationController
  include UserSession

  helper_method :current_user

  def index
  end

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user&.authenticate(sign_in_params[:password])
      sign_in(user)
      redirect_back fallback_location: admin_index_path
    else
      render :index
    end
  end

  def sign_in_params
    params.expect(user: [:email, :password])
  end
end
