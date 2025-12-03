# Unscoped version of the Membership model for niche User -> Membership
# interactions e.g. All Accounts a User is within
class UserMembership < ApplicationRecord
  self.table_name = :memberships

  belongs_to :account, primary_key: :reference, foreign_key: :account_reference
  belongs_to :user
  belongs_to :role

  def readonly?
    true
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord
  end
end
