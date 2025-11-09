module Middleware
  class AccountSwitch
    def initialize(app)
      @app = app
    end

    def call(env)
      path_segments = env["PATH_INFO"].to_s.split("/").reject(&:blank?)
      account_reference = path_segments[0] == "admin" ? path_segments[1] : nil

      Rails.logger.info "Account Reference: #{account_reference.inspect}, derived from: #{env["PATH_INFO"]}"

      Switch.account(account_reference) {
        @app.call(env)
      }
    end
  end
end
