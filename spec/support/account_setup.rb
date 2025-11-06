RSpec.configure do |config|
  config.around(:each) do |example|
    if example.metadata[:unscoped]
      example.run
    else
      account_1 = Account.create!(reference: "primary", name: "Primary Account")
      AccountSetting.create!(account: account_1)
      user = nil
      Switch.account(account_1.reference) {
        role = Role.create!(name: "Admin", administrator: true)
        user = role.users.create!(email: "example@email.com", password: "randomlettersandnumbers")
      }
      account_2 = Account.create!(reference: "secondary", name: "Secondary Account")
      AccountSetting.create!(account: account_2)
      Switch.account(account_2.reference) {
        role = Role.create!(name: "Admin", administrator: true)
        role.memberships.create!(user: user)
      }

      Switch.account(account_1.reference) {
        example.run
      }
    end
  end
end
