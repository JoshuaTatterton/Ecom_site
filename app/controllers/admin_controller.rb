class AdminController < ApplicationController
  include UserSession

  before_action :require_sign_in, only: [ :show ]
  before_action :validate_user_account, only: [ :show ]

  def index
  end

  def show
  end
end
