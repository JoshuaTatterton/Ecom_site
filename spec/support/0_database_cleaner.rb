# Database cleaning needs to be run as higher priority as possible
# so is named as such to be imported first. Could rearrange folders
# or manually import but while this is the only file I'm fine with
# this.
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.around(:each) do |example|
    databases = Rails.configuration.database_configuration[ENV["RAILS_ENV"]].keys
    database_cleaners = databases.map { |config|
      DatabaseCleaner[:active_record, db: config.to_sym]
    }

    if [ :system ].include?(example.metadata[:type])
      database_cleaners.each { |cleaner| cleaner.strategy = :truncation }
    else
      database_cleaners.each { |cleaner| cleaner.strategy = :transaction }
    end

    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
