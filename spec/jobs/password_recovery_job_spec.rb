RSpec.describe PasswordRecoveryJob, type: :job do
  describe "#perform" do
    it "sends an email to the user" do
      # Arrange
      user = User.create(email: "new@user.com", name: "ME")

      token = "sweet_token"
      allow_any_instance_of(User).to receive(:password_reset_token).and_return(token)

      # Act
      PasswordRecoveryJob.new.perform(user.id)

      # Assert
      aggregate_failures do
        # email delivered
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        email_delivery = ActionMailer::Base.deliveries.first
        expect(email_delivery.to).to eq([ user.email ])
        expect(email_delivery.subject).to eq("Reset Your Password")
        expect(email_delivery.body.encoded).to include(admin_password_reset_index_url({ token: token }))
      end
    end
  end
end
