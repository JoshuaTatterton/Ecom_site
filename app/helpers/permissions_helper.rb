module PermissionsHelper
  USER_PERMISSIONS = [
    { "resource" => "roles", "action" => "view" }, { "resource" => "roles", "action" => "create" }, 
    { "resource" => "roles", "action" => "update" }, { "resource" => "roles", "action" => "delete" } ]
  ALL_PERMISSIONS = USER_PERMISSIONS

  # Map permissions into PERMISSIONS format each param should look like:
  # { resource: { action: "true" } }
  # Stop processing and add active record error if it doesn't match this format
  def self.add_sanitized_form_permissions(role, permission_params)
    permissions = permission_params.values.map do |permission|
      if permission.keys.count == 1
        resource = permission.keys[0]
        action_param = permission.values[0]

        if action_param.keys.count == 1
          action = action_param.keys[0]

          if action_param.values[0] == "true"
            { resource: resource, action: action }
          else
            throw PermissionsInvalidError
          end
        else
          throw PermissionsInvalidError
        end
      else
        throw PermissionsInvalidError
      end
    end

    role.permissions = permissions
  rescue PermissionsInvalidError
    role.errors.add(:permissions, :invalid)
  end

  class PermissionsInvalidError < StandardError; end
end
