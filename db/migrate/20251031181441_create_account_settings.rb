class CreateAccountSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :account_settings do |t|
      t.string :account_reference, null: false, index: { unique: true, name: "unique_account_settings" }

      t.string :product_prefix
      t.string :category_prefix
      t.string :bundle_prefix

      t.timestamps
    end
  end
end
