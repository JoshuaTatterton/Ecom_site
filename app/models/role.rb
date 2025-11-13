class Role < ApplicationRecord
  include AccountScoped

  PERMISSIONS_SCHEMA = Rails.root.join("app", "schemas", "role_permissions.json_schema")

  has_many :memberships
  has_many :users, through: :memberships

  attr_readonly :administrator

  validates :name, presence: true, uniqueness: { scope: :account_reference }
  validates :permissions, json: { schema: PERMISSIONS_SCHEMA }
  validate :cannot_update_administrator_role, if: :administrator, on: :update

  before_destroy :prevent_administrator_role_destruction, if: :administrator

  private

  def cannot_update_administrator_role
    errors.add(:administrator, :cannot_update)
  end

  def prevent_administrator_role_destruction
    errors.add(:administrator, :cannot_destroy)
    raise ActiveRecord::RecordNotDestroyed
  end
end
