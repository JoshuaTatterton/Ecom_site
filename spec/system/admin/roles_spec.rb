RSpec.describe "Roles Admin", type: :system do
  describe "#index" do
    scenario "viewing roles" do
      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      aggregate_failures do
        expect(page).to have_content("Admin")
        expect(page).to have_selector("a[href='#{new_admin_role_path("primary")}']")
      end
    end
  end
end
