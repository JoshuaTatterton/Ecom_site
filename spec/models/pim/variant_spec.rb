RSpec.describe Pim::Variant, type: :model do
  it "is creatable" do
    # Arrange
    product = Pim::Product.create(
      reference: "product",
      title: "Product"
    )

    # Act
    created_variant = Pim::Variant.create(
      reference: "variant",
      title: "Variant",
      visible: true,
      product: product
    )

    # Assert
    expect(created_variant).to be_persisted
  end

  context "validations" do
    describe "#reference" do
      it "is required" do
        # Act
        variant = Pim::Variant.new

        # Assert
        aggregate_failures do
          expect(variant).to be_invalid
          expect(variant.errors).to be_added(:reference, :blank)
        end
      end

      it "is readonly" do
        # Arrange
        original_reference = "old"
        product = Pim::Product.create(reference: "product", title: "Product")
        variant = product.variants.create(
          reference: original_reference,
          title: "Variant"
        )

        # Act & Assert
        expect {
          variant.update(reference: "new")
        }.to raise_error(ActiveRecord::ReadonlyAttributeError, "reference")
      end

      it "is unique per Account" do
        # Arrange
        variant_reference = "Unique"
        product_1 = Pim::Product.create(reference: "product_1", title: "Product1")
        product_1.variants.create(
          reference: variant_reference,
          title: "Variant"
        )
        product_2 = Pim::Product.create(reference: "product_2", title: "Product2")

        # Act
        variant = product_2.variants.new(
          reference: variant_reference,
          title: "Another Variant"
        )

        # Assert
        aggregate_failures do
          expect(variant).to be_invalid
          expect(variant.errors).to be_added(:reference, :taken, value: variant_reference)
        end
      end

      it "can be used in another Account" do
        # Arrange
        variant_reference = "Unique"
        product = Pim::Product.create(reference: "product", title: "Product")
        product.variants.create(
          reference: variant_reference,
          title: "Variant"
        )

        # Act
        variant = Switch.account(@secondary_account.reference) do
          other_product = Pim::Product.create(reference: "product", title: "Product")
          Pim::Variant.new(
            reference: variant_reference,
            title: "Another Variant",
            product: other_product
          )
        end

        # Assert
        expect(variant).to be_valid
      end
    end

    describe "#title" do
      it "is required" do
        # Act
        variant = Pim::Variant.new

        # Assert
        aggregate_failures do
          expect(variant).to be_invalid
          expect(variant.errors).to be_added(:title, :blank)
        end
      end
    end

    describe "#visible" do
      it "defaults to false" do
        # Arrange
        product = Pim::Product.create(reference: "product", title: "Product")

        # Act
        variant = product.variants.create(
          reference: "variant",
          title: "Variant"
        )

        # Assert
        expect(variant.visible).to eq(false)
      end
    end

    describe "#product" do
      it "is required" do
        # Act
        variant = Pim::Variant.new

        # Assert
        aggregate_failures do
          expect(variant).to be_invalid
          expect(variant.errors).to be_added(:product, :blank)
        end
      end
    end

    describe "#position" do
      it "is defaulted to 0 as the only product variant" do
        # Arrange
        product = Pim::Product.create(reference: "product", title: "Product")

        # Act
        variant = Pim::Variant.new(reference: "variant", title: "Variant", product: product)

        # Assert
        aggregate_failures do
          expect(variant).to be_valid
          expect(variant.position).to eq(0)
        end
      end

      it "is defaulted to the variant count on the product" do
        # Arrange
        product = Pim::Product.create(reference: "product", title: "Product")
        3.times { |i| product.variants.create(reference: "v#{i}", title: "V#{i}") }

        # Act
        variant = product.variants.new(reference: "variant", title: "Variant")

        # Assert
        aggregate_failures do
          expect(variant).to be_valid
          expect(variant.position).to eq(3)
        end
      end
    end
  end
end
