# Database cleaning needs to be run as higher priority as possible
# so is names as such to be imported first  
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
