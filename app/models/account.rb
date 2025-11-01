# One per account record containing the system level config (not to be modified by Users)
# e.g. database configs or account feature toggles
class Account < ApplicationRecord
  has_one :account_setting, primary_key: :reference, foreign_key: :account_reference

  validates :name, :reference, presence: true
  validates :reference, uniqueness: true

  def self.current
    find_by(reference: Switch.current_account)
  end
end
