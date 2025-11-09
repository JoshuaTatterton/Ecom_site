class AdminController < ApplicationController
  include UserSession

  helper_method :current_user

  def index
  end

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user&.authenticate(sign_in_params[:password])
      sign_in(user)

      if request.referer&.end_with?(admin_index_path) && current_user.accounts.count == 1
        redirect_to admin_path(current_user.accounts.first.reference)
      else
        redirect_back_or_to admin_index_path
      end
    else
      render :index
    end
  end

  def show
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
