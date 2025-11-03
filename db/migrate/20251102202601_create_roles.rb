class CreateRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :roles do |t|
      t.string :account_reference, null: false
      t.string :name, null: false

      t.boolean :administrator, null: false, default: false
      t.jsonb :permissions, null: false, default: []

      t.timestamps
    end
  end
end
