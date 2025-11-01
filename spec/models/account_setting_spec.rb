RSpec.describe AccountSetting, type: :model do
  let(:account) { Account.create(name: "Ecom", reference: "ecom") }
  let(:account_setting) { AccountSetting.new(account: account) }

  it "creates when connected to an account" do
    # Act
    account_setting.save!

    # Assert
    expect(account_setting).to be_persisted
  end

  describe ".current" do
    let!(:account_setting) { AccountSetting.create(account: account) }

    it "finds the account settings for the currently switched account" do
      # Arrange
      found_settings = nil

      # Act
      Switch.account(account_setting.account_reference) {
        found_settings = AccountSetting.current
      }

      # Assert
      expect(found_settings).to eq(account_setting)
    end

    it "returns nil if no account settings exists for the currently switched account" do
      # Arrange
      found_settings = "AAAHHHHHHH"

      # Act
      Switch.account("AAAHHHHHHH") {
        found_settings = AccountSetting.current
      }

      # Assert
      expect(found_settings).to eq(nil)
    end
  end

  context "validates" do
    context "product_prefix" do
      it "cannot be longer than 48 characters" do
        # Act
        account_setting.product_prefix = SecureRandom.alphanumeric(49)

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:product_prefix, :too_long, count: 48)
      end

      it "is a valid URI path" do
        # Act
        account_setting.product_prefix = "hello world!"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:product_prefix, :invalid_path)
      end

      it "contains only a URI path" do
        # Act
        account_setting.product_prefix = "www.zombo.com/hello?x=y"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:product_prefix, :invalid_path)
      end
    end

    context "category_prefix" do
      it "cannot be longer than 48 characters" do
        # Act
        account_setting.category_prefix = SecureRandom.alphanumeric(49)

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:category_prefix, :too_long, count: 48)
      end

      it "is a valid URI path" do
        # Act
        account_setting.category_prefix = "hello world!"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:category_prefix, :invalid_path)
      end

      it "contains only a URI path" do
        # Act
        account_setting.category_prefix = "www.zombo.com/hello?x=y"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:category_prefix, :invalid_path)
      end
    end

    context "bundle_prefix" do
      it "cannot be longer than 48 characters" do
        # Act
        account_setting.bundle_prefix = SecureRandom.alphanumeric(49)

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:bundle_prefix, :too_long, count: 48)
      end

      it "is a valid URI path" do
        # Act
        account_setting.bundle_prefix = "hello world!"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:bundle_prefix, :invalid_path)
      end

      it "contains only a URI path" do
        # Act
        account_setting.bundle_prefix = "www.zombo.com/hello?x=y"

        # Assert
        expect(account_setting).to be_invalid
        expect(account_setting.errors).to be_added(:bundle_prefix, :invalid_path)
      end
    end
  end
end
