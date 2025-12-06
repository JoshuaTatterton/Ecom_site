RSpec.describe Currency, type: :model do
  it "all currencies are valid" do
    # Act
    currencies = CurrencyHelper::CURRENCIES.map { |_, config|
      Currency.new(config)
    }

    # Assert
    aggregate_failures do
      currencies.each do |currency|
        expect(currency).to be_valid
      end
    end
  end

  describe "#default" do
    context "on creating a new default: true" do
      it "sets other defaults to false" do
        # Arrange
        gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
        secondary_gbp = Switch.account(@secondary_account.reference) {
          Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
        }

        # Act
        usd = Currency.create(default: true, **CurrencyHelper::CURRENCIES["USD"])

        # Assert
        aggregate_failures do
          expect(gbp.reload.default).to eq(false)
          expect(usd.reload.default).to eq(true)
          Switch.account(@secondary_account.reference) {
            expect(secondary_gbp.reload.default).to eq(true)
          }
        end
      end
    end

    context "on updating an existing default: true" do
      it "sets other defaults to false" do
        # Arrange
        gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
        secondary_gbp = Switch.account(@secondary_account.reference) {
          Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
        }
        usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

        # Act
        usd.update(default: true)

        # Assert
        aggregate_failures do
          expect(gbp.reload.default).to eq(false)
          expect(usd.reload.default).to eq(true)
          Switch.account(@secondary_account.reference) {
            expect(secondary_gbp.reload.default).to eq(true)
          }
        end
      end
    end
  end

  context "validations" do
    describe "valid_currency_configuration" do
      it "configuration has to be correct for ISO" do
        # Act
        currency = Currency.new(
          **CurrencyHelper::CURRENCIES["USD"],
          iso: "GBP"
        )

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:base, :invalid_currency)
        end
      end
    end

    describe "#name" do
      it "is required" do
        # Act
        currency = Currency.new

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:name, :blank)
        end
      end
    end

    describe "#iso" do
      it "is required" do
        # Act
        currency = Currency.new

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:iso, :blank)
        end
      end

      it "is one of the CurrencyHelper::CURRENCY_ISOS" do
        # Act
        currency = Currency.new(iso: "UNKNOWN")

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:iso, :inclusion, value: "UNKNOWN")
        end
      end

      it "is unique per Account" do
        # Arrange
        gbp = Currency.create(CurrencyHelper::CURRENCIES["GBP"])

        # Act
        new_currency = Currency.create(CurrencyHelper::CURRENCIES["GBP"])

        # Assert
        aggregate_failures do
          expect(new_currency).to be_invalid
          expect(new_currency.errors).to be_added(:iso, :taken, value: gbp.iso)
        end
      end
    end

    describe "#code" do
      it "is required" do
        # Act
        currency = Currency.new

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:code, :blank)
        end
      end
    end

    describe "#symbol" do
      it "is required" do
        # Act
        currency = Currency.new

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:symbol, :blank)
        end
      end
    end

    describe "#decimals" do
      it "is required" do
        # Act
        currency = Currency.new

        # Assert
        aggregate_failures do
          expect(currency).to be_invalid
          expect(currency.errors).to be_added(:decimals, :blank)
        end
      end
    end
  end
end
