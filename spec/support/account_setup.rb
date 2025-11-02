RSpec.configure do |config|
  config.around(:each) do |example|
    account = Account.new(reference: "primary", name: "Primary Account")
    AccountSetting.create!(account: account)

    Switch.account(account.reference) {
      example.run
    }
  end
end
