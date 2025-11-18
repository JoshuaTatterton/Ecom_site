RSpec.describe UserMailer, type: :mailer do
  describe "#sign_up" do
    it "emails the user with link to user" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(email: "new@user.com", authentication_password: "SweetPassword")
      token = "sweet_token"
      allow(user).to receive(:authentication_password_reset_token).and_return(token)

      # Act
      email = UserMailer.sign_up(user)

      # Assert
      aggregate_failures do
        expect(email.to).to eq([user.email])
        expect(email.subject).to eq("Complete Your Sign Up")
        expect(email.body.encoded).to include("Account: #{role.account.name}")
        expect(email.body.encoded).to include("href=\"#{admin_user_sign_up_url({ token: token })}\"")
      end
    end
  end
end
