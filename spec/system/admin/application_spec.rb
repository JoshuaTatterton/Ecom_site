RSpec.describe "Admin::ApplicationController", type: :system do
  context "while signed out", signed_out: true do
    scenario "redirects to user login from any page" do
      # Act
      visit admin_roles_path(Switch.current_account)

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
          visit admin_roles_path(Switch.current_account)
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
