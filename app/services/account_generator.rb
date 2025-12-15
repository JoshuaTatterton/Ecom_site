# Account Generation Service - Accounts shouldn't be user generated (at least initially)
# they are to only be generated for clients manually either via a Rake task or potential
# super user admin.
# Service is to automatically create all aspects required for immediate usage.
#   - Account
#   - AccountSetting
#   - User (Soon)
#   - Role (Soon)
class AccountGenerator
  def initialize(reference:, name: nil, email:)
    @account_reference = reference
    @account_name = name || reference.camelize
    @user_email = email
  end

  def call!
    account = Account.new(reference: @account_reference, name: @account_name)

    Account.transaction do
      account.save!
      AccountSetting.create!(account: account)
      Switch.account(account.reference) do
        role = Role.create!(name: "Admin", administrator: true)
        @user = User.find_or_initialize_by(email: @user_email)
        role.memberships.create!(user: @user)
      end
    end

    Switch.account(account.reference) do
      UserSignUpJob.perform_async(@user.id) if @user.previously_new_record?
    end
  end
end
