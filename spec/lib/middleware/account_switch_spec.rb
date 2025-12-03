RSpec.describe Middleware::AccountSwitch, unscoped: true do
  it "sets account when it can be derived from the url path" do
    # Arrange
    fake_app = Proc.new { |env| { env: env, account: Switch.current_account } }
    middleware = Middleware::AccountSwitch.new(fake_app)

    account = "my_account"
    fake_env = { "PATH_INFO" => "//admin///#{account}/hello//world/" }

    # Act
    middleware_response = middleware.call(fake_env)

    # Assert
    aggregate_failures do
      expect(middleware_response[:env]).to eq(fake_env)
      expect(middleware_response[:account]).to eq(account)
    end
  end

  it "doesn't set account when account reference cannot be derived" do
    # Arrange
    fake_app = Proc.new { |env| { env: env, account: Switch.current_account } }
    middleware = Middleware::AccountSwitch.new(fake_app)

    account = "my_account"
    fake_env = { "PATH_INFO" => "/other/#{account}/hello/world/" }

    # Act
    middleware_response = middleware.call(fake_env)

    # Assert
    aggregate_failures do
      expect(middleware_response[:env]).to eq(fake_env)
      expect(middleware_response[:account]).to eq(nil)
    end
  end

  it "safely handles env with no data" do
    # Arrange
    fake_app = Proc.new { |env| { env: env, account: Switch.current_account } }
    middleware = Middleware::AccountSwitch.new(fake_app)

    fake_env = {}

    # Act
    middleware_response = middleware.call(fake_env)

    # Assert
    aggregate_failures do
      expect(middleware_response[:env]).to eq(fake_env)
      expect(middleware_response[:account]).to eq(nil)
    end
  end
end
