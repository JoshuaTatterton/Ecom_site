RSpec.describe Role, type: :model do
  it "is creatable with permissions" do
    # Act
    role = Role.create(name: "Basic", permissions: [{ resource: "product", permission: "create" }])

    # Assert
    expect(role).to be_persisted
  end

  it "is creatable as an admin" do
    # Act
    role = Role.create(name: "Basic", administrator: true)

    # Assert
    expect(role).to be_persisted
  end

  context "validations" do
    describe "#name" do
      it "is required" do
        # Act
        role = Role.new

        # Assert
        aggregate_failures do
          expect(role).to be_invalid
          expect(role.errors).to be_added(:name, :blank)
        end
      end
    end

    describe "#permissions" do
      it "must be valid json format" do
        # Arrange
        invalid_permissions = [{ "this_makes" => "no_sense" }]

        # Act
        role = Role.new(name: "Bare", permissions: invalid_permissions)

        # Assert
        aggregate_failures do
          expect(role).to be_invalid
          errors = role.errors.group_by_attribute
          expect(errors[:permissions].length).to eq(1)
          expect(errors[:permissions][0].type).to eq(:invalid_json)
        end
      end
    end
  end
end
