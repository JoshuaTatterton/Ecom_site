RSpec.describe "Users Admin", type: :system do
  describe "#index" do
    scenario "viewing users" do
      # Arrange
      admin_user = User.first
      admin_role = admin_user.role
      sweet_role = Role.create(name: "Sweet Role")
      sweet_user = sweet_role.users.create(email: "awaiting@authorization.com")

      # Act
      visit admin_users_path(Switch.current_account)

      # Assert
      aggregate_failures do
        within("tbody#users") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(sweet_user.email)
            expect(page).to have_content(sweet_role.name)
            # edit_path = edit_admin_user_path(Switch.current_account, sweet_role.id)
            # expect(page).to have_selector("a[href='#{edit_path}']")
            # delete_path = admin_user_path(Switch.current_account, sweet_role.id)
            # expect(page).to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(admin_user.name)
            expect(page).to have_content(admin_user.email)
            expect(page).to have_content(admin_role.name)
            # edit_path = edit_admin_user_path(Switch.current_account, admin_role.id)
            # expect(page).not_to have_selector("a[href='#{edit_path}']")
            # delete_path = admin_user_path(Switch.current_account, admin_role.id)
            # expect(page).not_to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
        end
        expect(page).to have_selector("a[href='#{new_admin_user_path(Switch.current_account)}']")
      end
    end
  end

  describe "#create" do
    context "when email doesn't match an existing user" do
      scenario "can create a new user and membership" do
        # Arrange
        role = Role.create(name: "Sweet Role")

        # Act
        visit new_admin_user_path(Switch.current_account)

        within("form[action='#{admin_users_path(Switch.current_account)}']") do
          find("input[name='user[email]']").fill_in(with: "new@user.com")
          find("select[name='user[role]']").select(role.name)

          find("input[type='submit']").click
        end

        # Assert
        aggregate_failures do
          expect(page).to have_content("new@user.com")
          expect(role.users.count).to eq(1)
          new_user = role.users.first
          expect(new_user.email).to eq("new@user.com")
          expect(new_user.awaiting_authentication).to eq(true)
        end
      end
    end

    context "when user already exists" do
      context "with a membership in another account" do
        scenario "can create a membership for the current account" do
          # Arrange
          role = Role.create(name: "Sweet Role")
          existing_user = nil
          Switch.account("secondary") {
            existing_user = Role.first.users.create(email: "new@user.com")
          }

          # Act
          visit new_admin_user_path(Switch.current_account)

          within("form[action='#{admin_users_path(Switch.current_account)}']") do
            find("input[name='user[email]']").fill_in(with: existing_user.email)
            find("select[name='user[role]']").select(role.name)

            find("input[type='submit']").click
          end

          # Assert
          aggregate_failures do
            expect(page).to have_content("new@user.com")
            expect(role.users.count).to eq(1)
            expect(role.users.first).to eq(existing_user)
          end
        end
      end

      context "with a membership in the current account" do
        scenario "does not create another user/membership" do
          # Arrange
          role = Role.create(name: "Sweet Role")
          existing_role = Role.create(name: "Existing")
          existing_user = existing_role.users.create(email: "new@user.com")

          # Act
          visit new_admin_user_path(Switch.current_account)

          within("form[action='#{admin_users_path(Switch.current_account)}']") do
            find("input[name='user[email]']").fill_in(with: existing_user.email)
            find("select[name='user[role]']").select(role.name)

            find("input[type='submit']").click
          end

          # Assert
          aggregate_failures do
            # email kept in field not rendered on page
            expect(page).not_to have_content("new@user.com")
            expect(find("input[name='user[email]']").value).to eq(existing_user.email)
            expect(role.users.count).to eq(0)
          end
        end
      end
    end

    context "when creating a user as an administrator" do
      scenario "can create a user with the administrator role" do
        # Arrange
        admin_role = Role.create(name: "Sweet Admin Role", administrator: true)

        # Act
        visit new_admin_user_path(Switch.current_account)

        within("form[action='#{admin_users_path(Switch.current_account)}']") do
          find("input[name='user[email]']").fill_in(with: "new@user.com")
          find("select[name='user[role]']").select(admin_role.name)

          find("input[type='submit']").click
        end

        # Assert
        aggregate_failures do
          expect(page).to have_content("new@user.com")
          expect(admin_role.users.count).to eq(1)
          new_user = admin_role.users.first
          expect(new_user.email).to eq("new@user.com")
          expect(new_user.awaiting_authentication).to eq(true)
        end
      end
    end

    context "when creating a user as a non administrator" do
      scenario "no administrator roles appear in the select" do
        # Arrange
        non_admin_role = Role.create(name: "Non-Admin", permissions: [
          { resource: "users", action: "add" }, { resource: "users", action: "view" }
        ])
        non_admin_user = non_admin_role.users.create(email: "nonadmin@user.com")
        page.set_rack_session(user_id: non_admin_user.id)

        admin_role = Role.create(name: "Sweet Admin Role", administrator: true)

        # Act
        visit new_admin_user_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within("form[action='#{admin_users_path(Switch.current_account)}']") do
            within("select[name='user[role]']") do
              expect(all("option").count).to eq 2
              expect(all("option")[0]).to have_content("- Select -")
              expect(all("option")[1]).to have_content(non_admin_role.name)
            end
          end
        end
      end

      scenario "cannot create a user with the administrator role" do
        # Arrange
        non_admin_role = Role.create(name: "Non-Admin", permissions: [
          { resource: "users", action: "add" }, { resource: "users", action: "view" }
        ])
        non_admin_user = non_admin_role.users.create(email: "nonadmin@user.com")
        page.set_rack_session(user_id: non_admin_user.id)

        admin_role = Role.create(name: "Sweet Admin Role", administrator: true)

        # Act
        # Using driver submit to test malicious behaviour
        page.driver.submit :post, admin_users_path(Switch.current_account), {
          user: {
            role: admin_role.id,
            email: "new@user.com"
          }
        }

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_users_path(Switch.current_account))
          expect(page).not_to have_content("new@user.com")

          expect(User.find_by(email: "new@user.com")).to be_nil
          expect(admin_role.users.count).to eq(0)
        end
      end
    end
  end

  # describe "#update" do
  #   scenario "can update a role name, add and remove permissions" do
  #     # Arrange
  #     role = Role.create(name: "AHHHH", permissions: [ { "resource" => "roles", "action" => "update" } ])

  #     # Act
  #     visit edit_admin_role_path(Switch.current_account, role.id)

  #     within("form[action='#{admin_role_path(Switch.current_account, role.id)}']") do
  #       find("input[name='role[name]']").fill_in(with: "Sweet Role")
  #       within("#user_permissions") do
  #         find("input[name='role[permissions][roles][create]']").click
  #         find("input[name='role[permissions][roles][update]']").click
  #       end
  #       find("input[type='submit']").click
  #     end

  #     # Assert
  #     aggregate_failures do
  #       expect(page).to have_content("Sweet Role")
  #       expect(role.reload.name).to eq("Sweet Role")
  #       expect(role.permissions).to eq([ { "resource" => "roles", "action" => "create" } ])
  #     end
  #   end
  # end

  # describe "#destroy" do
  #   scenario "can destroy a role" do
  #     # Arrange
  #     role = Role.create(name: "AHHHH")

  #     visit admin_roles_path(Switch.current_account)

  #     # Act
  #     within("tr#role_#{role.id}") do
  #       find("a[href='#{admin_role_path(Switch.current_account, role.id)}']").click
  #     end

  #     # Assert
  #     aggregate_failures do
  #       expect(page).not_to have_content(role.name)
  #       expect(Role.find_by(id: role.id)).to eq(nil)
  #     end
  #   end
  # end
end
