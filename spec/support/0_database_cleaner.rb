# Database cleaning needs to be run as higher priority as possible
# so is named as such to be imported first. Could rearrange folders
# or manually import but while this is the only file I'm fine with
# this.
require 'database_cleaner/active_record'

RSpec.configure do |config|
  config.before(:suite) do
    [ ApplicationRecord, PimRecord ].each do |klass|
      cleaner = DatabaseCleaner[:active_record, db: klass]
      cleaner.strategy = :truncation
      cleaner.clean
    end
  end

  config.around(:each) do |example|
    # Abstract records for dedicated databases to be added here:
    database_cleaners = [ ApplicationRecord, PimRecord ].map { |klass|
      DatabaseCleaner[:active_record, db: klass]
    }

    if [ :system ].include?(example.metadata[:type])
      database_cleaners.each { |cleaner| cleaner.strategy = :truncation }
    else
      database_cleaners.each { |cleaner| cleaner.strategy = :transaction }
    end

    database_cleaners.each(&:start)

    example.run

    database_cleaners.each(&:clean)
  end
end
