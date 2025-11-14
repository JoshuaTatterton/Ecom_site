module UserSession
  extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      helper_method :current_user
    end
  end

  def signed_in?
    session[:user_id].present?
  end

  def sign_in(user)
    session[:user_id] = user.id
  end

  def sign_out!
    session.delete(:sign_in_redirect)
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user
    @current_user ||= signed_in? && User.includes(:accounts).find(session[:user_id])
  end

  def require_sign_in
    if !signed_in?
      session[:sign_in_redirect] = request.fullpath
      redirect_to admin_index_path
    end
  end

  def sign_in_redirect
    if session[:sign_in_redirect]
      # Redirect back if possible
      redirect_location = session[:sign_in_redirect]
      session.delete(:sign_in_redirect)
      redirect_location
    elsif current_user.accounts.count == 1
      # Redirect to account page if user is attached to 1 account
      admin_path(current_user.accounts.first.reference)
    else
      # Redirect to base admin page if user is attached to multiple accounts
      admin_index_path
    end
  end
end
