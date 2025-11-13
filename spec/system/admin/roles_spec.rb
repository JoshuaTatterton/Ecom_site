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
            edit_path = edit_admin_role_path(Switch.current_account, sweet_role.id)
            expect(page).to have_selector("a[href='#{edit_path}']")
            delete_path = admin_role_path(Switch.current_account, sweet_role.id)
            expect(page).to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(admin_role.name)
            edit_path = edit_admin_role_path(Switch.current_account, admin_role.id)
            expect(page).not_to have_selector("a[href='#{edit_path}']")
            delete_path = admin_role_path(Switch.current_account, admin_role.id)
            expect(page).not_to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
        end
        expect(page).to have_selector("a[href='#{new_admin_role_path("primary")}']")
      end
    end
  end

  describe "#create" do
    scenario "can create a role with no permissions" do
      # Act
      visit new_admin_role_path(Switch.current_account)

      within("form[action='#{admin_roles_path(Switch.current_account)}']") do
        find("input[name='role[name]']").fill_in(with: "Sweet Role")
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("Sweet Role")
        created_role = Role.find_by(name: "Sweet Role")
        expect(created_role.permissions).to eq([])
      end
    end

    scenario "can create a role with all permissions" do
      # Act
      visit new_admin_role_path(Switch.current_account)

      within("form[action='#{admin_roles_path(Switch.current_account)}']") do
        find("input[name='role[name]']").fill_in(with: "Sweet Role")
        all("input[type='checkbox']").each(&:click)
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("Sweet Role")
        created_role = Role.find_by(name: "Sweet Role")
        expect(created_role.permissions).to eq(PermissionsHelper::ALL_PERMISSIONS)
      end
    end
  end

  describe "#update" do
    scenario "can update a role name, add and remove permissions" do
      # Arrange
      role = Role.create(name: "AHHHH", permissions: [{ "resource" => "roles", "action" => "update" }])

      # Act
      visit edit_admin_role_path(Switch.current_account, role.id)

      within("form[action='#{admin_role_path(Switch.current_account, role.id)}']") do
        find("input[name='role[name]']").fill_in(with: "Sweet Role")
        within("#user_permissions") do
          find("input[name='role[permissions][roles][create]']").click
          find("input[name='role[permissions][roles][update]']").click
        end
        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content("Sweet Role")
        expect(role.reload.name).to eq("Sweet Role")
        expect(role.permissions).to eq([{ "resource" => "roles", "action" => "create" }])
      end
    end
  end

  describe "#destroy" do
    scenario "can destroy a role" do
      # Arrange
      role = Role.create(name: "AHHHH")

      visit admin_roles_path(Switch.current_account)

      # Act
      within("tr#role_#{role.id}") do
        find("a[href='#{admin_role_path(Switch.current_account, role.id)}']").click
      end

      # Assert
      aggregate_failures do
        expect(page).not_to have_content(role.name)
        expect(Role.find_by(id: role.id)).to eq(nil)
      end
    end
  end
end
