# One per account record containing the account level config which should be everything
# configurable by an account user.
# e.g. url prefixes or default search params
class AccountSetting < ApplicationRecord
  belongs_to :account, primary_key: :reference, foreign_key: :account_reference

  validates :product_prefix, length: { maximum: 48 }
  validates :category_prefix, length: { maximum: 48 }
  validates :bundle_prefix, length: { maximum: 48 }

  validates_each :product_prefix, :category_prefix, :bundle_prefix do |record, attr, value|
    record.errors.add(attr, :invalid_path) if value && record.valid_path?(value)
  end

  # A basic path validator to ensure there is nothing that breaks 
  def valid_path?(value)
    uri = URI.parse(value)
    uri.path != value
  rescue URI::InvalidURIError
    true
  end

  def self.current
    find_by(account_reference: Switch.current_account)
  end
end
