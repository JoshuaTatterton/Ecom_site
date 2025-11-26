RSpec.configure do |config|
  config.around(:each) do |example|
    account_1 = Account.create!(reference: "primary", name: "Primary Account")
    AccountSetting.create!(account: account_1)
    user = nil
    Switch.account(account_1.reference) {
      role = Role.create!(name: "Admin", administrator: true)
      user = role.users.create!(
        name: "Example User",
        email: "example@email.com",
        password: "randomlettersandnumbers",
        awaiting_authentication: false
      )
    }
    account_2 = Account.create!(reference: "secondary", name: "Secondary Account")
    AccountSetting.create!(account: account_2)
    Switch.account(account_2.reference) {
      role = Role.create!(name: "Admin", administrator: true)
      role.memberships.create!(user: user)
    }

    if example.metadata[:unscoped]
      example.run
    else
      Switch.account(account_1.reference) {
        example.run
      }
    end
  end

  config.before(:each, type: :system) do |example|
    if !example.metadata[:signed_out]
      user = User.first
      page.set_rack_session(user_id: user.id)
    end
  end
end
