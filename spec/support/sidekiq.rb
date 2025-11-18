Sidekiq.logger.level = Logger::WARN

RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline! do
        example.run
      end
    elsif example.metadata[:sidekiq] == :disabled
      Sidekiq::Testing.disabled! do
        example.run
      end
    else
      example.run
    end
  end

  config.after(:each) do
    Sidekiq::Worker.clear_all
  end
end
