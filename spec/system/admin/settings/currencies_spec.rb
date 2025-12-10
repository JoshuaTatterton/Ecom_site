RSpec.describe "Currencies Admin", type: :system do
  describe "#index" do
    scenario "viewing currencies" do
      # Arrange
      gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
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
            expect(find("input#currency_default")).not_to be_checked
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.name)
            expect(page).to have_content(gbp.iso)
            expect(page).to have_content(gbp.code)
            expect(page).to have_content(gbp.symbol)
            expect(page).not_to have_selector("svg.bi-check-circle")
            expect(find("input#currency_default")).to be_checked
          end
        end
      end
    end

    context "when a user without update currency_defaults permissions" do
      scenario "only displays that a currency is the default" do
        # Arrange
        gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
        usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

        role = Role.create(name: "AHHHH", permissions: [ { "resource" => "currencies", "action" => "view" } ])
        user = role.users.create(
          email: "test@user.com",
          name: "Old Name",
          password: "SuperSecretPassword",
          awaiting_authentication: false
        )
        page.set_rack_session(user_id: user.id)

        # Act
        visit admin_currencies_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within("tbody#currencies") do
            within("tr:nth-child(1)") do
              expect(page).to have_content(usd.iso)
              expect(page).not_to have_selector("svg.bi-check-circle")
              expect(page).not_to have_selector("input#currency_default")
            end
            within("tr:nth-child(2)") do
              expect(page).to have_content(gbp.iso)
              expect(page).to have_selector("svg.bi-check-circle")
              expect(page).not_to have_selector("input#currency_default")
            end
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
      gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])

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
            expect(find("input#currency_default")).to be_checked
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.iso)
            expect(find("input#currency_default")).not_to be_checked
          end
        end
      end
    end

    context "when a user without update currency_defaults permissions" do
      scenario "there is no option to make the currency the default", js: true do
        # Arrange
        role = Role.create(name: "AHHHH", permissions: [
          { "resource" => "currencies", "action" => "view" },
          { "resource" => "currencies", "action" => "add" }
        ])
        user = role.users.create(
          email: "test@user.com",
          name: "Old Name",
          password: "SuperSecretPassword",
          awaiting_authentication: false
        )
        page.set_rack_session(user_id: user.id)

        visit admin_currencies_path(Switch.current_account)

        # Act
        find("[data-bs-toggle='modal'][data-bs-target='#new_currency_modal']").click

        # Assert
        within("form[action='#{admin_currencies_path(Switch.current_account)}']") do
          expect(page).not_to have_selector("input#currency_default")
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
    scenario "can add default to a currency", js: true do
      # Arrange
      gbp = Currency.create(CurrencyHelper::CURRENCIES["GBP"])

      visit admin_currencies_path(Switch.current_account)

      # Act
      within("tbody#currencies") do
        find("input#currency_default").click
      end
      accept_confirm

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(find("input#currency_default")).to be_checked
            expect(gbp.reload.default).to eq(true)
          end
        end
      end
    end

    scenario "can remove default from a currency", js: true do
      # Arrange
      gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])

      visit admin_currencies_path(Switch.current_account)

      # Act
      within("tbody#currencies") do
        find("input#currency_default").click
      end
      accept_confirm

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(find("input#currency_default")).not_to be_checked
            expect(gbp.reload.default).to eq(false)
          end
        end
      end
    end

    scenario "can move default from one currency to another", js: true do
      # Arrange
      gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
      usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

      visit admin_currencies_path(Switch.current_account)

      # Act
      within("tr#currency_#{usd.id}") do
        find("input#currency_default").click
      end
      accept_confirm

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(usd.iso)
            expect(find("input#currency_default")).to be_checked
            expect(usd.reload.default).to eq(true)
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.iso)
            expect(find("input#currency_default")).not_to be_checked
            expect(gbp.reload.default).to eq(false)
          end
        end
      end
    end

    scenario "cancels update when rejecting confirm", js: true do
      # Arrange
      gbp = Currency.create(default: true, **CurrencyHelper::CURRENCIES["GBP"])
      usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

      visit admin_currencies_path(Switch.current_account)

      # Act
      within("tr#currency_#{usd.id}") do
        find("input#currency_default").click
      end
      dismiss_confirm

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(find("input#currency_default")).not_to be_checked
            expect(usd.reload.default).to eq(false)
          end
          within("tr:nth-child(2)") do
            expect(find("input#currency_default")).to be_checked
            expect(gbp.reload.default).to eq(true)
          end
        end
      end
    end
  end

  describe "#destroy" do
    scenario "can remove a currency" do
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

    scenario "cannot remove the default currency" do
      # Arrange
      usd = Currency.create(**CurrencyHelper::CURRENCIES["USD"], default: true)

      # Act
      visit admin_currencies_path(Switch.current_account)

      # Assert
      within("tr#currency_#{usd.id}") do
        expect(page).not_to have_selector("a[href='#{admin_currency_path(Switch.current_account, usd.id)}']")
      end
    end
  end
end
