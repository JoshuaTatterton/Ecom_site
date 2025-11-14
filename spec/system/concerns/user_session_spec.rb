RSpec.describe "User Session Admin", type: :system do
  context "while signed out", signed_out: true do
    scenario "renders user login from any page" do
      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      expect(page).to have_selector("form[action='/admin/sign_in']")
    end
  end
end
