class Membership < ApplicationRecord
  include AccountScoped

  belongs_to :user
  belongs_to :role

  validates :user, uniqueness: { scope: :account_reference }
end
