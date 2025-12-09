namespace :account do
  # Example usage rake account:generate ACCOUNT_REFERENCE= ACCOUNT_NAME= ADMIN_USER_EMAIL=
  desc "Generate Account and associated resources"
  task generate: :environment do
    account_reference = ENV.fetch("ACCOUNT_REFERENCE")
    account_name = ENV.fetch("ACCOUNT_NAME", nil)
    user_email = ENV.fetch("ADMIN_USER_EMAIL")

    generator = AccountGenerator.new(
      reference: account_reference,
      name: account_name,
      email: user_email
    )

    generator.call!
  end
end
