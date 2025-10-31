class Account < ApplicationRecord
  has_one :account_setting, primary_key: :reference, foreign_key: :account_reference

  validates :name, :reference, presence: true
  validates :reference, uniqueness: true
end
