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
        expect(email.to).to eq([ user.email ])
        expect(email.subject).to eq("Complete Your Sign Up")
        expect(email.body.encoded).to include("Account: <strong>#{role.account.name}</strong>")
        expect(email.body.encoded).not_to include("an account.")
        expect(email.body.encoded).to include("href=\"#{admin_sign_up_index_url({ token: token })}\"")
      end
    end

    context "when outside of an account scope" do
      it "emails the user without account identifier" do
        # Arrange
        role = Role.create(name: "Sweet Role")
        user = role.users.create(email: "new@user.com", authentication_password: "SweetPassword")
        token = "sweet_token"
        allow(user).to receive(:authentication_password_reset_token).and_return(token)

        Switch.account(nil) {
          # Act
          email = UserMailer.sign_up(user)

          # Assert
          aggregate_failures do
            expect(email.to).to eq([ user.email ])
            expect(email.subject).to eq("Complete Your Sign Up")
            expect(email.body.encoded).to include("an account.")
            expect(email.body.encoded).not_to include("Account:")
          end
        }
      end
    end
  end

  describe "#password_recovery" do
    it "emails the user with link to user" do
      # Arrange
      user = User.create(email: "new@user.com", name: "ME")

      token = "sweet_token"
      allow(user).to receive(:password_reset_token).and_return(token)

      # Act
      email = UserMailer.password_recovery(user)

      # Assert
      aggregate_failures do
        expect(email.to).to eq([ user.email ])
        expect(email.subject).to eq("Reset Your Password")
        expect(email.body.encoded).to include(user.name)
        expect(email.body.encoded).to include(admin_password_reset_index_url({ token: token }))
      end
    end
  end
end
