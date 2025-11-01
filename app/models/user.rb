# Single sign in multi-account User.
class User < ApplicationRecord
  include ActiveModel::SecurePassword

  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, unless: :awaiting_authentication
  # Validate blank is allowed because of has_secure_password default
  # validations we want to keep after authenticating
  validate :password_blank_allowed, if: :awaiting_authentication

  private

  def password_blank_allowed
    errors.delete(:password, :blank)
  end
end
