RSpec.describe Ability do
  describe ".current_account" do
    it "returns the reference of the currently scoped account" do
      # Arrange
      reference = nil

      # Act
      Switch.account("account") {
        reference = Switch.current_account
      }

      # Assert
      expect(reference).to eq("account")
    end
  end
end
