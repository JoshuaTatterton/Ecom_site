# Database cleaning needs to be run as higher priority as possible
# so is named as such to be imported first. Could rearrange folders
# or manually import but while this is the only file I'm fine with
# this.
require 'database_cleaner/active_record'

DatabaseCleaner.strategy = :transaction

RSpec.configure do |config|
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
