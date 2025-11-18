Rails.root.glob("lib/middleware/sidekiq/**/*.rb").sort_by(&:to_s).each { |f| require f }

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
  config.logger = Rails.logger

  config.client_middleware do |chain|
    chain.add Middleware::Sidekiq::Client::AccountStore
  end
end

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }
  config.logger = Rails.logger

  config.server_middleware do |chain|
    chain.add Middleware::Sidekiq::Server::AccountSwitch
  end
end
