RSpec.describe AccountSetting, type: :model do
  let(:account) { Account.create(name: "Ecom", reference: "ecom") }
  let(:account_setting) { AccountSetting.new(account: account) }

  it "creates when connected to an account" do
    # Act
    account_setting.save!

    # Assert
    expect(account_setting).to be_persisted
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
  end
end
