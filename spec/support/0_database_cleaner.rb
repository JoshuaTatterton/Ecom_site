# Database cleaning needs to be run as higher priority as possible
# so is named as such to be imported first. Could rearrange folders
# or manually import but while this is the only file I'm fine with
# this.
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.around(:each) do |example|
    if [ :system ].include?(example.metadata[:type])
      DatabaseCleaner.strategy = :truncation
    else
      DatabaseCleaner.strategy = :transaction
    end

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
