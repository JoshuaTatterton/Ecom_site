class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :reference, null: false, index: { unique: true, name: "unique_accounts" }
      t.timestamps
    end
  end
end
