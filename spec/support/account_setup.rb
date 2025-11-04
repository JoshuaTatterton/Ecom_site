RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:unscoped]
      example.run
    else
      account_1 = Account.new(reference: "primary", name: "Primary Account")
      AccountSetting.create!(account: account_1)
      account_2 = Account.new(reference: "secondary", name: "Secondary Account")
      AccountSetting.create!(account: account_2)

      Switch.account(account_1.reference) {
        example.run
      }
    end
  end
end
