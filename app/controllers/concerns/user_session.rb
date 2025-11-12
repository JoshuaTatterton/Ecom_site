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
    session.delete(:user_id)
    @current_user = nil
  end

  def current_user
    @current_user ||= signed_in? && User.includes(:accounts).find(session[:user_id])
  end
end
