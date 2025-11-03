class Role < ApplicationRecord
  include AccountScoped

  PERMISSIONS_SCHEMA = Rails.root.join("app", "schemas", "role_permissions.json_schema")

  has_many :memberships
  has_many :users, through: :memberships

  validates :name, presence: true, uniqueness: true
  validates :permissions, json: { schema: PERMISSIONS_SCHEMA }
end
