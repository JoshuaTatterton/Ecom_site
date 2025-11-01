# A lot of these tests will be tests around ActiveModel::SecurePassword as a learning
# experience on the methods I want to use.
RSpec.describe User, type: :model do
  it "is creatable with only an email" do
    # Act
    user = User.create(email: "real@email.com")

    # Assert
    expect(user).to be_persisted
  end

  context "validations" do
    context "#email" do
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

    context "#name" do
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

    context "#password" do
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
  end
end
