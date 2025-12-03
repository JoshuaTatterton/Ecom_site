class AddProducts < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :products do |t|
      t.string :account_reference, null: false
      t.string :reference, null: false
      t.string :title, null: false

      t.text :description

      t.boolean :visible, null: false, default: false

      t.timestamps
    end

    add_index :products,
      [ :account_reference, :reference ],
      unique: true,
      name: "unique_account_product_references",
      algorithm: :concurrently
  end
end
