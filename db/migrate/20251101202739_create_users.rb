class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true, name: "unique_users" }
      t.string :name

      t.string :password_digest
      t.string :recovery_password_digest

      t.boolean :awaiting_authentication, null: false, default: true

      t.timestamps
    end

    # Users may be created with only an email but can only be used once
    # other data has been provided.
    constraint = "awaiting_authentication = true OR %{field} IS NOT NULL"
    add_check_constraint :users, constraint % { field: "name" }, name: "user_name_required"
    add_check_constraint :users, constraint % { field: "password_digest" }, name: "user_password_required"
  end
end
