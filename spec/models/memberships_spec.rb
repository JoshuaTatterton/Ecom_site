RSpec.describe Membership, type: :model do
  context "validations" do
    describe "#account_reference" do
      it "only allows one membership per user per account" do
        # Arrange
        user = User.create(email: "real@email.com")
        role1 = Role.create(name: "Basic", permissions: [ { resource: "product", action: "create" } ])
        role2 = Role.create(name: "Basicer", permissions: [ { resource: "product", action: "create" } ])

        # Act
        initial_membership = Membership.create(user: user, account_reference: Switch.current_account, role: role1)
        second_membership = Membership.create(user: user, account_reference: Switch.current_account, role: role2)

        # Assert
        aggregate_failures do
          expect(initial_membership).to be_persisted
          expect(second_membership).not_to be_persisted
        end
      end
    end
  end
end
