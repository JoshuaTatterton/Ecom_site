RSpec.describe "Admin", type: :system, signed_out: true do
  describe "#index" do
    scenario "can sign in" do
      # Arrange
      visit admin_index_path

      # Act
      within("form[action='/admin/sign_in']") do
        find("input[name='user[email]']").fill_in(with: "example@email.com")
        find("input[name='user[password]']").fill_in(with: "randomlettersandnumbers")
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)
        expect(page).not_to have_content("Sign in")
        expect(page).to have_content("example@email.com")
        expect(page).to have_selector("a[href='#{admin_path("primary")}']")
        expect(page).to have_selector("a[href='#{admin_path("secondary")}']")
      end
    end

    context "when signing in as a User attached to one Account" do
      scenario "redirects to the account's admin page by default" do
        # Arrange
        user = Role.last.users.create!(email: "single@account.com", password: "randomlettersandnumbers")

        visit admin_index_path

        # Act
        within("form[action='/admin/sign_in']") do
          find("input[name='user[email]']").fill_in(with: user.email)
          find("input[name='user[password]']").fill_in(with: user.password)
          find("input[type='submit']").click
        end

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_path(user.accounts.first.reference))
          expect(page).to have_content(user.email)
          expect(page).to have_content(user.accounts.first.name)
        end
      end
    end

    context "when signing in from a redirected page" do
      scenario "redirects to the original page" do
        # Arrange
        user = Role.last.users.create!(email: "single@account.com", password: "randomlettersandnumbers")

        visit admin_roles_path(Switch.current_account)

        # Act
        within("form[action='/admin/sign_in']") do
          find("input[name='user[email]']").fill_in(with: user.email)
          find("input[name='user[password]']").fill_in(with: user.password)
          find("input[type='submit']").click
        end

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_roles_path(Switch.current_account))
          expect(page).to have_content(user.email)
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
          expect(current_path).to eq(admin_path("secondary"))
          expect(page).to have_content("Secondary Account")
        end
      end
    end

    context "while signed out" do
      scenario "redirects to user login" do
        # Act
        visit admin_path(Switch.current_account)

        # Assert
        expect(current_path).to eq(admin_index_path)
        expect(page).to have_selector("form[action='/admin/sign_in']")
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

  describe "#destroy" do
    scenario "can sign out", js: true do
      # Arrange
      user = User.first
      page.set_rack_session(user_id: user.id)

      visit admin_path(Switch.current_account)

      # Act
      within(".navbar") do
        find("#user_nav").click
        find("a[data-turbo-method='delete']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)
        expect(page).not_to have_content(user.email)
        expect(page).to have_content("Sign in")
      end
    end
  end
end
