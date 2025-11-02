# A lot of these tests will be tests around ActiveModel::SecurePassword as a learning
# experience on the methods I want to use, the tests may be removed once the provided
# methods are actually used.
RSpec.describe User, type: :model do
  it "is creatable with only an email" do
    # Act
    user = User.create(email: "real@email.com")

    # Assert
    expect(user).to be_persisted
  end

  context "validations" do
    describe "#email" do
      it "is required" do
        # Act
        user = User.new

        # Assert
        aggregate_failures do
          expect(user).to be_invalid
          expect(user.errors).to be_added(:email, :blank)
        end
      end

      it "must be a valid email" do
        # Arrange
        invalid_email = "..."

        # Act
        user = User.new(email: invalid_email)

        # Assert
        aggregate_failures do
          expect(user).to be_invalid
          expect(user.errors).to be_added(:email, :invalid, value: invalid_email)
        end
      end
    end

    describe "#name" do
      it "is required when awaiting_authentication: false" do
        # Act
        user = User.new(email: "real@email.com", awaiting_authentication: false)

        # Assert
        aggregate_failures do
          expect(user).to be_invalid
          expect(user.errors).to be_added(:name, :blank)
        end
      end

      it "is DB required when awaiting_authentication: false" do
        # Arrange
        user = User.create(
          email: "real@email.com",
          password: "password",
          password_confirmation: "password"
        )

        # Act & Assert
        expect {
          user.update_columns(awaiting_authentication: false)
        }.to raise_error(ActiveRecord::CheckViolation, /user_name_required/)
      end
    end

    describe "#password" do
      it "is required when awaiting_authentication: false" do
        # Act
        user = User.new(email: "real@email.com", awaiting_authentication: false)

        # Assert
        aggregate_failures do
          expect(user).to be_invalid
          expect(user.errors).to be_added(:password, :blank)
        end
      end

      it "is DB required when awaiting_authentication: false" do
        # Arrange
        user = User.create(email: "real@email.com", name: "me")

        # Act & Assert
        expect {
          user.update_columns(awaiting_authentication: false)
        }.to raise_error(ActiveRecord::CheckViolation, /user_password_required/)
      end
    end

    describe "#password_challenge" do
      it "can validate an update with a password challenge" do
        # Arrange
        email = "real@email.com"
        password = "AHHHHHH"
        user = User.create(email: email, password: password, password_confirmation: password)

        # Act
        user.update(name: "yugtfdxfcgvh", password_challenge: password)

        # Assert
        expect(user.errors).to be_empty
      end

      it "rejects update with an incorrect password challenge" do
        # Arrange
        email = "real@email.com"
        password = "AHHHHHH"
        user = User.create(email: email, password: password, password_confirmation: password)

        # Act
        incorrect_passord = "#{password}1"
        user.update(name: "yugtfdxfcgvh", password_challenge: incorrect_passord)

        # Assert
        expect(user.errors).to be_added(:password_challenge, :invalid)
      end
    end
  end

  describe "#authenticate" do
    it "validates a password" do
      # Arrange
      email = "real@email.com"
      password = "AHHHHHH"
      user = User.create(email: email, password: password, password_confirmation: password)

      # Act
      auth_output = User.find_by(email: email).authenticate(password)

      # Assert
      expect(auth_output).to eq(user)
    end

    it "rejects an invalid password" do
      # Arrange
      email = "real@email.com"
      password = "AHHHHHH"
      user = User.create(email: email, password: password)

      # Act
      incorrect_passord = "#{password}1"
      auth_output = User.find_by(email: email).authenticate(incorrect_passord)

      # Assert
      expect(auth_output).to eq(false)
    end
  end

  describe "#password_reset_token" do
    it "generates a token" do
      # Arrange
      email = "real@email.com"
      password = "AHHHHHH"
      user = User.create(email: email, password: password, password_confirmation: password)

      # Act
      token = user.password_reset_token

      # Assert
      expect(token).not_to be_nil
    end

    it "finds User via token" do
      # Arrange
      email = "real@email.com"
      password = "AHHHHHH"
      user = User.create(email: email, password: password, password_confirmation: password)
      token = user.password_reset_token

      # Act
      found_user = User.find_by_password_reset_token(token)

      # Assert
      expect(found_user).to eq(user)
    end

    it "rejects an invalid user token" do
      # Arrange
      email = "real@email.com"
      password = "AHHHHHH"
      user = User.create(email: email, password: password, password_confirmation: password)
      token = user.password_reset_token

      # Act
      found_user = User.find_by_password_reset_token("iuhygtfghjk")

      # Assert
      expect(found_user).to eq(nil)
    end
  end
end
