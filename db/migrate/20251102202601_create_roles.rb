class CreateRoles < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :roles do |t|
      t.string :account_reference, null: false
      t.string :name, null: false

      t.boolean :administrator, null: false, default: false
      t.jsonb :permissions, null: false, default: []

      t.timestamps
    end

    add_index :roles,
      [ :account_reference, :name ],
      unique: true,
      name: "unique_account_role_names",
      algorithm: :concurrently
  end
end
