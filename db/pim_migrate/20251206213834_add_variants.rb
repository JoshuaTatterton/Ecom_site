class AddVariants < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :variants do |t|
      t.string :account_reference, null: false
      t.string :reference, null: false
      t.belongs_to :product, null: false

      t.string :title, null: false
      t.boolean :visible, null: false, default: false

      t.timestamps
    end

    add_index :variants,
      [ :account_reference, :reference ],
      unique: true,
      name: "unique_account_variant_references",
      algorithm: :concurrently
  end
end
