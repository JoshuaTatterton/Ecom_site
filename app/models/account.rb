class Account < ApplicationRecord
  validates :name, :reference, presence: true
  validates :reference, uniqueness: true
end
