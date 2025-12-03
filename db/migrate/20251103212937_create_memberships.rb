class CreateMemberships < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :memberships do |t|
      t.string :account_reference, null: false

      t.belongs_to :user, null: false
      t.belongs_to :role, null: false

      t.timestamps
    end

    add_index :memberships,
      [ :account_reference, :user_id ],
      unique: true,
      name: "unique_user_account_memberships",
      algorithm: :concurrently
  end
end
