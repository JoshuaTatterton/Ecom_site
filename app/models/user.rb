# Single sign in multi-account User.
class User < ApplicationRecord
  include ActiveModel::SecurePassword

  # Relationships outside of the account scope
  has_many :user_memberships
  has_many :accounts, through: :user_memberships

  # Relationships within the account scope
  has_one :membership
  has_one :role, through: :membership

  has_secure_password
  has_secure_password :recovery_password, validations: false

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :name, presence: true, unless: :awaiting_authentication
  # Validate blank is allowed because of has_secure_password default
  # validations we want to keep after authenticating
  validate :password_blank_allowed, if: :awaiting_authentication

  # TODO
  # normalizes :email_address, with: -> e { e.strip.downcase }

  private

  def password_blank_allowed
    errors.delete(:password, :blank)
  end
end
