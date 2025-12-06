module PermissionsHelper
  PRODUCT_PERMISSIONS = [
    { "resource" => "products", "action" => "view" }, { "resource" => "products", "action" => "create" },
    { "resource" => "products", "action" => "update" }, { "resource" => "products", "action" => "delete" },
    { "resource" => "variants", "action" => "view" }, { "resource" => "variants", "action" => "create" },
    { "resource" => "variants", "action" => "update" }, { "resource" => "variants", "action" => "delete" }
  ]
  AUTH_PERMISSIONS = [
    { "resource" => "users", "action" => "view" }, { "resource" => "users", "action" => "add" },
    { "resource" => "user_roles", "action" => "update" }, { "resource" => "users", "action" => "remove" },
    { "resource" => "roles", "action" => "view" }, { "resource" => "roles", "action" => "create" },
    { "resource" => "roles", "action" => "update" }, { "resource" => "roles", "action" => "delete" }
  ]
  SETTINGS_PERMISSIONS = [
    { "resource" => "currencies", "action" => "view" }, { "resource" => "currencies", "action" => "add" },
    { "resource" => "currency_defaults", "action" => "update" }, { "resource" => "currencies", "action" => "remove" }
  ]
  ALL_PERMISSIONS = PRODUCT_PERMISSIONS + AUTH_PERMISSIONS + SETTINGS_PERMISSIONS

  RESOURCE_MAP = {
    "products" => Pim::Product,
    "roles" => Role,
    "users" => Membership,
    "user_roles" => Membership,
    "currencies" => Currency,
    "currency_defaults" => Currency
  }

  # Map permissions into PERMISSIONS format each param should look like:
  # { resource: { action_1: "true", action_2: "true", ... }, ... }
  def self.serialized_form_permissions(permission_params)
    permission_params.keys.each_with_object([]) do |resource, permissions|
      permission_params[resource].each do |action, value|
        permissions << { resource: resource, action: action } if value == "true"
      end
    end
  end

  def self.permitted_params
    ALL_PERMISSIONS.each_with_object({}) do |permission, param|
      resource = permission["resource"]
      action = permission["action"]
      param[resource] ||= []
      param[resource] << action
    end
  end
end
