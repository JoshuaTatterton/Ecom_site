Rails.root.glob('lib/middleware/**/*.rb').sort_by(&:to_s).each { |f| require f }

Rails.application.configure do
  config.middleware.use Middleware::AccountSwitch
end
