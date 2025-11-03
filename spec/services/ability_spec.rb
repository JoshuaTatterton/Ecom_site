RSpec.describe Ability do
  let(:role) { Role.create(name: "a", permissions: [ { resource: "role", action: "create" } ]) }

  it "returns true when role permission is allowed" do
    # Act
    ability = Ability.new(role)

    # Assert
    expect(ability.can?(:create, :role)).to eq(true)
  end

  it "returns false when role permission is not allowed" do
    # Act
    ability = Ability.new(role)

    # Assert
    expect(ability.can?(:burn, :everything)).to eq(false)
  end

  it "has global permissions with account administrator role" do
    # Arrange
    role = Role.create(name: "a", administrator: true, permissions: [])

    # Act
    ability = Ability.new(role)

    # Assert
    expect(ability.can?(:burn, :everything)).to eq(true)
  end
end
