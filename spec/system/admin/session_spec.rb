RSpec.describe "Session Admin", type: :system, signed_out: true do
  describe "#create" do
    scenario "can sign in" do
      # Arrange
      visit admin_index_path

      # Act
      within("form[action='/admin/session/sign_in']") do
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
        within("form[action='/admin/session/sign_in']") do
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
        within("form[action='/admin/session/sign_in']") do
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
