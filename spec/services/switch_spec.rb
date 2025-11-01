RSpec.describe Switch do
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

    it "returns the nil when unscoped" do
      # Act
      reference = Switch.current_account

      # Assert
      expect(reference).to eq(nil)
    end
  end

  describe ".switch" do
    it "scopes the current thread to the requested account" do
      # Arrange
      switched_reference = nil

      # Act
      Switch.account("account") {
        switched_reference = Thread.current[Switch::CURRENT_ACCOUNT_KEY]
      }

      # Assert
      expect(switched_reference).to eq("account")
    end

    it "de-scopes the current thread after the block is completed" do
      # Act
      Switch.account("account") { }
      switched_reference = Thread.current[Switch::CURRENT_ACCOUNT_KEY]

      # Assert
      expect(switched_reference).to eq(nil)
    end

    it "can scope and de-scope multiple times" do
      # Arrange
      switched_a_reference = nil
      switched_b_reference = nil

      # Act
      Switch.account("a") {
        Switch.account("b") {
          switched_b_reference = Thread.current[Switch::CURRENT_ACCOUNT_KEY]
        }
        switched_a_reference = Thread.current[Switch::CURRENT_ACCOUNT_KEY]
      }

      # Assert
      aggregate_failures do
        expect(switched_a_reference).to eq("a")
        expect(switched_b_reference).to eq("b")
      end
    end
  end
end
