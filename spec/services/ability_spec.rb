RSpec.describe Ability do
  let(:role) { Role.create(name: "a", permissions: [ { resource: "role", action: "create" } ]) }
  let(:user) { role.users.create(email: "real@email.com") }

  it "returns true when role permission is allowed" do
    # Act
    ability = Ability.new(user)

    # Assert
    expect(ability.can?(:create, :role)).to eq(true)
  end

  it "returns false when role permission is not allowed" do
    # Act
    ability = Ability.new(user)

    # Assert
    expect(ability.can?(:burn, :everything)).to eq(false)
  end

  it "has global permissions with account administrator role" do
    # Arrange
    role = Role.create(name: "a", administrator: true, permissions: [])
    user = role.users.create(email: "real@email.com")

    # Act
    ability = Ability.new(user)

    # Assert
    expect(ability.can?(:burn, :everything)).to eq(true)
  end
end
