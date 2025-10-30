namespace :account do
  desc "Generate Account and associated resources"
  task generate: :environment do
    account_reference = ENV.fetch("ACCOUNT_REFERENCE")
    account_name = ENV.fetch("ACCOUNT_NAME", nil)

    generator = AccountGenerator.new(reference: account_reference, name: account_name)

    generator.call!
  end
end
