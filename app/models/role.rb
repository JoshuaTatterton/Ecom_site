class Role < ApplicationRecord
  include AccountScoped

  validates :name, presence: true, uniqueness: true
end
