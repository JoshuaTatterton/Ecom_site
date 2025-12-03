RSpec.describe "Admin", type: :system, signed_out: true do
  describe "#index" do
    context "while signed out" do
      scenario "shows sign in form" do
        # Act
        visit admin_index_path

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_index_path)
          expect(page).to have_selector("form[action='/admin/session/sign_in']")
          expect(page).to have_content("Sign in")
        end
      end
    end

    context "while signed in", signed_out: false do
      scenario "displays account cards" do
        # Arrange
        missing_account = Account.create!(reference: "tertiary", name: "Tertiary Account")

        # Act
        visit admin_index_path

        # Assert
        aggregate_failures do
          expect(page).not_to have_selector("form[action='/admin/session/sign_in']")
          expect(page).to have_selector("a[href='#{admin_path("primary")}']")
          expect(page).to have_selector("a[href='#{admin_path("secondary")}']")
          expect(page).not_to have_selector("a[href='#{admin_path(missing_account.reference)}']")
        end
      end
    end
  end

  describe "#show" do
    it "displays admin page" do
      # Arrange
      user = User.first
      page.set_rack_session(user_id: user.id)

      # Act
      visit admin_path(Switch.current_account)

      # Assert
      aggregate_failures do
        expect(page).to have_content(user.email)
      end
    end

    context "with access to 1 account" do
      scenario "nav contains link to the account page" do
        # Arrange
        role = Role.first
        user = role.users.create(email: "wot@umean.com")
        page.set_rack_session(user_id: user.id)

        # Act
        visit admin_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within(".navbar") do
            expect(page).to have_selector("a[href='#{admin_path(Switch.current_account)}']")
            expect(page).not_to have_selector("a[href='#{admin_path("secondary")}']")
          end
        end
      end
    end

    context "with access to 2 or more accounts" do
      scenario "nav contains link to the other account", js: true do
        # Arrange
        user = User.first
        page.set_rack_session(user_id: user.id)

        # Act
        visit admin_path(Switch.current_account)

        within(".navbar") do
          find("#account_nav").click
          find("a[href='#{admin_path("secondary")}']").click
        end

        # Assert
        aggregate_failures do
          expect(page).to have_content("Secondary Account")
          expect(current_path).to eq(admin_path("secondary"))
        end
      end
    end

    context "while signed out" do
      scenario "redirects to user login" do
        # Act
        visit admin_path(Switch.current_account)

        # Assert
        expect(current_path).to eq(admin_index_path)
        expect(page).to have_selector("form[action='/admin/session/sign_in']")
      end
    end

    context "while signed in" do
      context "without access to an account" do
        scenario "redirects to the home page when trying to visit an unsolicited account's page" do
          # Arrange
          secondary_account = Account.find_by(reference: "secondary")
          primary_account_only_user = Role.first.users.create!(email: "random@email.co.uk")
          page.set_rack_session(user_id: primary_account_only_user.id)

          # Act
          Switch.account(secondary_account.reference) {
            visit admin_path(Switch.current_account)
          }

          # Assert
          aggregate_failures do
            expect(current_path).to eq(admin_index_path)
            expect(page).to have_selector("a[href='#{admin_path(Switch.current_account)}']")
            expect(page).not_to have_selector("a[href='#{admin_path(secondary_account.reference)}']")
          end
        end
      end
    end
  end
end
