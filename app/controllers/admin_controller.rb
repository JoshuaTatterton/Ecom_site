class AdminController < ApplicationController
  include UserSession

  before_action :require_sign_in, only: [ :show ]

  def index
  end

  def create
    user = User.find_by(email: sign_in_params[:email])
    if user&.authenticate(sign_in_params[:password])
      sign_in(user)

      redirect_to sign_in_redirect
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
