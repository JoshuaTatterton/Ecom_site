class AddUserAuthenticationPassword < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :authentication_password_digest, :string
  end
end
