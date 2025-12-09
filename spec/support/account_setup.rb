RSpec.configure do |config|
  config.around(:each) do |example|
    @primary_account = Account.create!(reference: "primary", name: "Primary Account")
    AccountSetting.create!(account: @primary_account)
    Switch.account(@primary_account.reference) {
      @primary_role = Role.create!(name: "All Access", permissions: PermissionsHelper::ALL_PERMISSIONS)
      @primary_user = @primary_role.users.create!(
        name: "Example User",
        email: "example@email.com",
        password: "randomlettersandnumbers",
        awaiting_authentication: false
      )
    }
    @secondary_account = Account.create!(reference: "secondary", name: "Secondary Account")
    AccountSetting.create!(account: @secondary_account)
    Switch.account(@secondary_account.reference) {
      @secondary_role = Role.create!(name: "All Access", permissions: PermissionsHelper::ALL_PERMISSIONS)
      @secondary_role.memberships.create!(user: @primary_user)
    }

    if example.metadata[:unscoped]
      example.run
    else
      Switch.account(@primary_account.reference) {
        example.run
      }
    end
  end

  config.before(:each, type: :system) do |example|
    if !example.metadata[:signed_out]
      page.set_rack_session(user_id: @primary_user.id)
    end
  end
end
