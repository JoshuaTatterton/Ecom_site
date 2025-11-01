RSpec.describe Account, type: :model do
  let(:account) { Account.new(name: "Ecom", reference: "ecom") }

  describe ".current" do
    let!(:account) { Account.create(name: "Ecom", reference: "ecom") }

    it "finds the account settings for the currently switched account" do
      # Arrange
      found_account = nil

      # Act
      Switch.account(account.reference) {
        found_account = Account.current
      }

      # Assert
      expect(found_account).to eq(account)
    end

    it "returns nil if no account account exists for the currently switched account" do
      # Arrange
      found_account = "AAAHHHHHHH"

      # Act
      Switch.account("AAAHHHHHHH") {
        found_account = Account.current
      }

      # Assert
      expect(found_account).to eq(nil)
    end
  end

  context "validates" do
    it "presence of name" do
      # Act
      account.name = nil

      # Assert
      expect(account).to be_invalid
      expect(account.errors).to be_added(:name, :blank)
    end

    it "presence of reference" do
      # Act
      account.reference = nil

      # Assert
      expect(account).to be_invalid
      expect(account.errors).to be_added(:reference, :blank)
    end

    it "uniqueness of reference" do
      # Arrange
      account.save

      # Act
      dupe_account = account.dup

      # Assert
      expect(dupe_account).to be_invalid
      expect(dupe_account.errors).to be_added(:reference, :taken, value: account.reference)
    end
  end
end
