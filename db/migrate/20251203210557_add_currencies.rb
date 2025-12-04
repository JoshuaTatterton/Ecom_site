class AddCurrencies < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    create_table :currencies do |t|
      t.string :account_reference, null: false

      t.string :name, null: false
      t.string :iso, null: false
      t.string :code, null: false
      t.string :symbol, null: false
      t.integer :decimals, null: false

      t.boolean :default, null: false, default: false

      t.timestamps
    end

    add_index :currencies,
      [ :account_reference, :iso ],
      unique: true,
      name: "unique_account_currency_iso",
      algorithm: :concurrently
  end
end
