RSpec.describe "Roles Admin", type: :system do
  describe "#index" do
    scenario "viewing roles" do
      # Arrange
      admin_role = User.first.role
      sweet_role = Role.create(name: "Sweet Role")

      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      aggregate_failures do
        within("tbody#roles") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(sweet_role.name)
            expect(page).to have_selector("a[href='#{edit_admin_role_path(Switch.current_account, sweet_role.id)}']")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(admin_role.name)
            expect(page).not_to have_selector("a[href='#{edit_admin_role_path(Switch.current_account, admin_role.id)}']")
          end
        end
        expect(page).to have_selector("a[href='#{new_admin_role_path("primary")}']")
      end
    end
  end

  describe "#create" do
    scenario "creating a role with all permissions" do
      # Act
      visit new_admin_role_path(Switch.current_account)

      within("form[action='#{admin_roles_path(Switch.current_account)}']") do
        find("input[name='role[name]']").fill_in(with: "Sweet Role")
        find("input[type='submit']").click
      end

      # Assert
      expect(page).to have_content("Sweet Role")
    end
  end

  describe "#update" do
    scenario "updating a role" do
      # Arrange
      role = Role.create(name: "AHHHH")

      # Act
      visit edit_admin_role_path(Switch.current_account, role.id)

      within("form[action='#{admin_role_path(Switch.current_account, role.id)}']") do
        find("input[name='role[name]']").fill_in(with: "Sweet Role")
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("Sweet Role")
        expect(role.reload.name).to eq("Sweet Role")
      end
    end
  end
end
