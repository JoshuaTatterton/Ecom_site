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

      it "is readonly" do
        # Arrange
        original_reference = "old"
        product = Pim::Product.create(
          reference: original_reference,
          title: "Product"
        )

        # Act & Assert
        expect {
          product.update(reference: "new")
        }.to raise_error(ActiveRecord::ReadonlyAttributeError, "reference")
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

    describe "#title" do
      it "is required" do
        # Act
        product = Pim::Product.new

        # Assert
        aggregate_failures do
          expect(product).to be_invalid
          expect(product.errors).to be_added(:title, :blank)
        end
      end
    end

    describe "#visible" do
      it "defaults to false" do
        # Act
        product = Pim::Product.create(
          reference: "product",
          title: "Product"
        )

        # Assert
        expect(product.visible).to eq(false)
      end
    end

    describe "#variants" do
      it "blocks deletion" do
        # Arrange
        product = Pim::Product.create(reference: "product", title: "Product")
        variant = product.variants.create(reference: "variant", title: "Variant")

        # Act
        product.destroy

        # Assert
        aggregate_failures do
          expect(Pim::Product.find(product.id)).to be_persisted
          expect(variant.reload).to be_persisted
          expect(product.errors).to be_added(:base, :"restrict_dependent_destroy.has_many", record: "variants")
        end
      end
    end
  end
end
