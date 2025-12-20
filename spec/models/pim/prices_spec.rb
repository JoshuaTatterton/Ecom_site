RSpec.describe Pim::Price, type: :model do
  let(:product) { Pim::Product.create(reference: "product", title: "Product") }
  let(:variant) { product.variants.create(reference: "product", title: "Product") }
  let(:currency) { Currency.create(CurrencyHelper::CURRENCIES["GBP"]) }

  describe "#starts_at" do
    it "is normalized to the minute" do
      # Arrange
      starts_at = 2.days.ago

      # Act
      price = variant.prices.create(
        currency: currency,
        amount: 10,
        starts_at: starts_at,
        ends_at: 2.days.from_now
      )

      # Assert
      expect(price.starts_at).to eq(starts_at.beginning_of_minute)
    end
  end

  describe "#ends_at" do
    it "is normalized to the minute" do
      # Arrange
      ends_at = 2.days.from_now

      # Act
      price = variant.prices.create(
        currency: currency,
        amount: 10,
        starts_at: 2.days.ago,
        ends_at: ends_at
      )

      # Assert
      aggregate_failures do
        expect(price).to be_persisted
        expect(price.ends_at).to eq(ends_at.beginning_of_minute)
      end
    end
  end

  describe "#active_during" do
    it "is persisted in the database" do
      # Arrange
      starts_at = 2.days.ago
      ends_at = 2.days.from_now

      # Act
      price = variant.prices.create(
        currency: currency,
        amount: 10,
        starts_at: starts_at,
        ends_at: ends_at
      )

      # Assert
      expect(price.reload.active_during).to eq(starts_at.beginning_of_minute...ends_at.beginning_of_minute)
    end
  end

  context "validations" do
    describe "#amount" do
      it "is required" do
        # Act
        price = variant.prices.new

        # Assert
        aggregate_failures do
          expect(price).to be_invalid
          expect(price.errors).to be_added(:amount, :blank)
        end
      end
    end

    describe "#was_amount" do
      it "must be greater than amount if present" do
        # Act
        price = variant.prices.new(amount: 10, was_amount: 5)

        # Assert
        aggregate_failures do
          expect(price).to be_invalid
          expect(price.errors).to be_added(:was_amount, :greater_than, value: 5, count: 10)
        end
      end
    end

    describe "#starts_at" do
      it "is required" do
        # Act
        price = variant.prices.new

        # Assert
        aggregate_failures do
          expect(price).to be_invalid
          expect(price.errors).to be_added(:starts_at, :blank)
        end
      end
    end

    describe "#ends_at" do
      it "is required" do
        # Act
        price = variant.prices.new

        # Assert
        aggregate_failures do
          expect(price).to be_invalid
          expect(price.errors).to be_added(:ends_at, :blank)
        end
      end

      it "must be after starts_at" do
        # Arrange
        past = 2.days.ago
        future = 2.days.from_now

        # Act
        price = variant.prices.new(
          amount: 1,
          starts_at: future,
          ends_at: past
        )

        # Assert
        aggregate_failures do
          expect(price).to be_invalid
          expect(price.errors).to be_added(
            :ends_at,
            :greater_than,
            count: future.beginning_of_minute,
            value: past.beginning_of_minute
          )
        end
      end
    end
  end
end
