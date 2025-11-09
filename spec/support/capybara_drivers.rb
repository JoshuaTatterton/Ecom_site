RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test, screen_size: [2560,1440]
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_headless, screen_size: [2560,1440]
  end
end
