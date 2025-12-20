RSpec.describe Switch, :unscoped do
  context "account switching" do
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

    describe ".account" do
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

  context "currency switching" do
    describe ".current_iso" do
      it "returns the iso of the currently scoped currency" do
        # Arrange
        iso = nil

        # Act
        Switch.currency("GBP") {
          iso = Switch.current_iso
        }

        # Assert
        expect(iso).to eq("GBP")
      end

      it "returns the nil when unscoped" do
        # Act
        iso = Switch.current_account

        # Assert
        expect(iso).to eq(nil)
      end
    end

    describe ".current_currency" do
      context "when not scoped inside an account" do
        it "returns the nil" do
          # Arrange
          currency = "AHHH"

          # Act
          Switch.currency("ISO") {
            currency = Switch.current_currency
          }

          # Assert
          expect(currency).to eq(nil)
        end
      end

      context "when scoped inside an account" do
        around(:each) do |example|
          Switch.account("primary") {
            example.run
          }
        end

        it "returns the Currency of the currently scoped iso" do
          # Arrange
          gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
          usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

          # Act
          currency = Switch.currency("USD") {
            Switch.current_currency
          }

          # Assert
          expect(currency).to eq(usd)
        end

        it "returns the default Currency when unscoped" do
          # Arrange
          gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])

          # Act
          currency = Switch.current_currency

          # Assert
          expect(currency).to eq(gbp)
        end

        it "returns nil when default Currency doesn't exist when unscoped" do
          # Arrange
          gbp = Currency.create(CurrencyHelper::CURRENCIES["GBP"])

          # Act
          currency = Switch.current_currency

          # Assert
          expect(currency).to eq(nil)
        end
      end
    end

    describe ".currency" do
      it "scopes the current thread to the requested currency" do
        # Arrange
        switched_currency = nil

        # Act
        Switch.currency("GBP") {
          switched_currency = Thread.current[Switch::CURRENT_CURRENCY_KEY]
        }

        # Assert
        expect(switched_currency).to eq("GBP")
      end

      it "de-scopes the current thread after the block is completed" do
        # Act
        Switch.currency("GBP") { }
        switched_currency = Thread.current[Switch::CURRENT_CURRENCY_KEY]

        # Assert
        expect(switched_currency).to eq(nil)
      end

      it "can scope and de-scope multiple times" do
        # Arrange
        switched_currency_a = nil
        switched_reference_b = nil

        # Act
        Switch.currency("GBP") {
          Switch.currency("USD") {
            switched_reference_b = Thread.current[Switch::CURRENT_CURRENCY_KEY]
          }
          switched_currency_a = Thread.current[Switch::CURRENT_CURRENCY_KEY]
        }

        # Assert
        aggregate_failures do
          expect(switched_currency_a).to eq("GBP")
          expect(switched_reference_b).to eq("USD")
        end
      end
    end
  end
end
