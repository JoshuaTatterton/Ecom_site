RSpec.describe "Currencies Admin", type: :system do
  describe "#index" do
    scenario "viewing currencies" do
      # Arrange
      gbp = Currency.create({ default: true }.merge(CurrencyHelper::CURRENCIES["GBP"]))
      usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

      # Act
      visit admin_currencies_path(Switch.current_account)

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(usd.name)
            expect(page).to have_content(usd.iso)
            expect(page).to have_content(usd.code)
            expect(page).to have_content(usd.symbol)
            expect(page).not_to have_selector("svg.bi-check-circle")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.name)
            expect(page).to have_content(gbp.iso)
            expect(page).to have_content(gbp.code)
            expect(page).to have_content(gbp.symbol)
            expect(page).to have_selector("svg.bi-check-circle")
          end
        end
      end
    end
  end

  describe "#create" do
    scenario "can add a currency", js: true do
      # Arrange
      visit admin_currencies_path(Switch.current_account)

      # Act
      find("[data-bs-toggle='modal'][data-bs-target='#new_currency_modal']").click

      within("form[action='#{admin_currencies_path(Switch.current_account)}']") do
        find("select[name='currency[iso]']").select("GBP (£)")

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("GBP")
        expect(page).not_to have_content("USD")
      end
    end

    scenario "can overwrite the default with a new currency", js: true do
      # Arrange
      gbp = Currency.create({ default: true }.merge(CurrencyHelper::CURRENCIES["GBP"]))

      visit admin_currencies_path(Switch.current_account)

      # Act
      find("[data-bs-toggle='modal'][data-bs-target='#new_currency_modal']").click

      within("form[action='#{admin_currencies_path(Switch.current_account)}']") do
        find("select[name='currency[iso]']").select("USD ($)")
        find("label[for='currency_default']").click

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(page).to have_content("USD")
            expect(page).to have_selector("svg.bi-check-circle")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.iso)
            expect(page).not_to have_selector("svg.bi-check-circle")
          end
        end
      end
    end

    scenario "is not available if there are no more currencies to add" do
      # Arrange
      CurrencyHelper::CURRENCIES.each do |_, currency_params|
        Currency.create(currency_params)
      end

      # Act
      visit admin_currencies_path(Switch.current_account)

      # Assert
      expect(page).not_to have_selector("[data-bs-toggle='modal'][data-bs-target='#new_currency_modal']")
    end
  end

  describe "#update" do
    scenario "can update a product" do
      # Arrange
      product = Pim::Product.create(title: "Sweet", reference: "sweet", visible: true)

      # Act
      visit edit_admin_product_path(Switch.current_account, product.id)

      within("form[action='#{admin_product_path(Switch.current_account, product.id)}']") do
        find("input[name='pim_product[title]']").fill_in(with: "Sweeter")
        find("label[for='pim_product_visible']").click
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("Sweeter")
        expect(product.reload.title).to eq("Sweeter")
        expect(product.visible).to eq(false)
      end
    end
  end

  describe "#destroy" do
    scenario "can destroy a product" do
      # Arrange
      usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

      visit admin_currencies_path(Switch.current_account)

      # Act
      within("tr#currency_#{usd.id}") do
        find("a[href='#{admin_currency_path(Switch.current_account, usd.id)}']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to have_content(admin_currencies_path(Switch.current_account))

        within("tbody") do
          expect(page).not_to have_content(usd.iso)
        end
      end
    end
  end
end
