RSpec.describe Role, type: :model do
  it "is creatable" do
    # Act
    role = Role.create(name: "Basic")

    # Assert
    expect(role).to be_persisted
  end
end
