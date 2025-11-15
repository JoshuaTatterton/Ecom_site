module PermissionsHelper
  USER_PERMISSIONS = [
    { "resource" => "roles", "action" => "view" }, { "resource" => "roles", "action" => "create" },
    { "resource" => "roles", "action" => "update" }, { "resource" => "roles", "action" => "delete" }
  ]
  ALL_PERMISSIONS = USER_PERMISSIONS

  RESOURCE_MAP = {
    "roles" => Role
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
