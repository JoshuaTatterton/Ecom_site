# A lot of these tests will be tests around ActiveModel::SecurePassword
RSpec.describe User, type: :model do
  it "is creatable with only an email" do
    # Act
    user = User.create(email: "real@email.com")

    # Assert
    expect(user).to be_persisted
  end

  context "validations" do
    context "#awaiting_authentication" do
    end
  end
end
