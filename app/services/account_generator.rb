# Account Generation Service - Accounts shouldn't be user generated (at least initially)
# they are to only be generated for clients manually either via a Rake task or potential
# super user admin.
# Service is to automatically create all aspects required for immediate usage.
#   - Account
#   - AccountSetting
#   - User (Soon)
#   - Role (Soon)
class AccountGenerator
  def initialize(reference:, name: nil)
    @account_reference = reference
    @account_name = name || reference.camelize
  end

  def call!
    account = Account.new(reference: @account_reference, name: @account_name)

    Account.transaction do
      account.save!
      AccountSetting.create!(account: account)
    end
  end
end
