require "sidekiq/web"

module Middleware
  module Sidekiq
    module Server
      class AccountSwitch
        include ::Sidekiq::ServerMiddleware

        # @param [Object] job_instance the instance of the job that was queued
        # @param [Hash] job_payload the full job payload
        #   * @see https://github.com/sidekiq/sidekiq/wiki/Job-Format
        # @param [String] queue the name of the queue the job was pulled from
        # @yield the next middleware in the chain or worker `perform` method
        # @return [Void]
        def call(job_instance, job_payload, queue)
          Rails.logger.info "AccountReference: #{job_payload["account_reference"].inspect} derived from job"

          Switch.account(job_payload["account_reference"]) {
            yield
          }
        end
      end
    end
  end
end
