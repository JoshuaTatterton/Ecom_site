module Authorize
  extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      around_action :catch_failed_authorize_redirect
    end
  end
  
  # Safe version of authorize! which will redirect to a safe location instead of  
  def authorize(*args)
    unless can?(*args)
      raise AuthorizationError
    end
  end

  def catch_failed_authorize_redirect
    yield
  rescue AuthorizationError
    if [ "index", "show" ].include?(action_name)
      redirect_to admin_path(Switch.current_account)
    else
      redirect_to action: :index
    end
  end

  class AuthorizationError < StandardError; end
end
