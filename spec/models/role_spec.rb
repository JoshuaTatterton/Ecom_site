RSpec.describe Role, type: :model do
  it "is creatable with permissions" do
    # Act
    role = Role.create(name: "Basic", permissions: [ { resource: "product", action: "create" } ])

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

      it "is unique per Account" do
        # Arrange
        role_name = "Unique"
        Role.create(name: role_name)

        # Act
        role = Role.new(name: role_name)

        # Assert
        aggregate_failures do
          expect(role).to be_invalid
          expect(role.errors).to be_added(:name, :taken, value: role_name)
        end
      end
    end

    describe "#permissions" do
      it "must be valid json format" do
        # Arrange
        invalid_permissions = [ { "this_makes" => "no_sense" } ]

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

    describe "#administrator" do
      it "can create an admin role" do
        # Act
        role = Role.create(name: "Administrator", administrator: true)

        # Assert
        expect(role).to be_persisted
      end

      it "cannot change :administrator" do
        # Arrange
        role = Role.create(name: "Administrator", administrator: false)

        # Act & Assert
        expect {
          role.update(administrator: true)
        }.to raise_error(ActiveRecord::ReadonlyAttributeError)
      end

      it "cannot update an admin role" do
        # Arrange
        role = Role.create(name: "Administrator", administrator: true)

        # Act & Assert
        role.update(name: "AAHHHHH")

        # Assert
        aggregate_failures do
          expect(role).to be_invalid
          errors = role.errors.group_by_attribute
          expect(errors[:administrator].length).to eq(1)
          expect(errors[:administrator][0].type).to eq(:cannot_update)
        end
      end

      it "cannot destroy an admin role" do
        # Arrange
        role = Role.create(name: "Administrator", administrator: true)

        # Act & Assert
        expect {
          role.reload.destroy
        }.to change(Role, :count).by(0)

        # Assert
        aggregate_failures do
          expect(role).to be_invalid
          errors = role.errors.group_by_attribute
          expect(errors[:administrator].length).to eq(1)
          expect(errors[:administrator][0].type).to eq(:cannot_update)
        end
      end
    end

    describe "#memberships" do
      it "cannot destroy a role with memberships" do
        # Arrange
        role = Role.create(name: "Who?")
        user = role.users.create(email: "user@email.com")

        # Act & Assert
        expect {
          role.destroy
        }.to change(Role, :count).by(0)

        # Assert
        expect(role.errors).to be_added(:base, :"restrict_dependent_destroy.has_many", record: "memberships")
      end
    end
  end
end
