RSpec.describe Pim::Product, type: :model do
  it "is creatable" do
    # Act
    created_product = Pim::Product.create(
      reference: "product",
      title: "Product",
      description: "Hello world thisis a sweet product you want to buy",
      visible: true
    )

    # Assert
    expect(created_product).to be_persisted
  end

  context "validations" do
    describe "#reference" do
      it "is required" do
        # Act
        product = Pim::Product.new

        # Assert
        aggregate_failures do
          expect(product).to be_invalid
          expect(product.errors).to be_added(:reference, :blank)
        end
      end

      it "is unique per Account" do
        # Arrange
        product_reference = "Unique"
        Pim::Product.create(
          reference: product_reference,
          title: "Product"
        )

        # Act
        product = Pim::Product.new(
          reference: product_reference,
          title: "Another Product"
        )

        # Assert
        aggregate_failures do
          expect(product).to be_invalid
          expect(product.errors).to be_added(:reference, :taken, value: product_reference)
        end
      end

      it "can be used in another Account" do
        # Arrange
        product_reference = "Unique"
        Pim::Product.create(
          reference: product_reference,
          title: "Product"
        )

        # Act
        product = Switch.account(@secondary_account.reference) do
          Pim::Product.new(
            reference: product_reference,
            title: "Another Product"
          )
        end

        # Assert
        expect(product).to be_valid
      end
    end
  end
end
