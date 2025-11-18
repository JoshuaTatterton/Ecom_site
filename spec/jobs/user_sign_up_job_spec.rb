RSpec.describe UserSignUpJob, type: :job do
  describe "#perform" do
    it "sends an email to the user for the membership" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(email: "new@user.com")
      membership = user.membership

      password = "MyPassword"
      allow(SecureRandom).to receive(:uuid).and_return(password)
      token = "sweet_token"
      allow_any_instance_of(User).to receive(:authentication_password_reset_token).and_return(token)

      # Act
      UserSignUpJob.new.perform(membership.id)

      # Assert
      aggregate_failures do
        # Password set to reset the salt
        expect(user.reload.authenticate_authentication_password(password)).to eq(user)
        # email delivered
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email_delivery = ActionMailer::Base.deliveries.first
        expect(email_delivery.to).to eq([user.email])
        expect(email_delivery.subject).to eq("Complete Your Sign Up")
        expect(email_delivery.body.encoded).to include(admin_user_sign_up_url({ token: token }))
      end
    end

    it "skips if user is already authenticated" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(email: "new@user.com", name: "me", password: "password", awaiting_authentication: false)
      puts user.errors.full_messages
      membership = user.membership

      # Act
      UserSignUpJob.new.perform(membership.id)

      # Assert
      aggregate_failures do
        expect(user.reload.authentication_password_digest).to eq(nil)
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
