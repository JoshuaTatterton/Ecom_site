RSpec.describe "Authorize Admin", type: :system do
  describe "#index" do
    scenario "can view with permissions" do
      # Arrange
      role = Role.create(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end

    scenario "redirects back to account page without permissions" do
      # Arrange
      role = Role.create(name: "no permissions :(", permissions: [])
      user = role.users.create(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      expect(current_path).to eq(admin_path(Switch.current_account))
    end
  end

  # Currently no show page to test on @TODO
  # describe "#show" do
  #   scenario "can view with permissions" do
  #     # Arrange
  #     role = Role.create(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
  #     user = role.users.create(email: "no@permissions.com")
  #     page.set_rack_session(user_id: user.id)

  #     visit_role = Role.create(name: "Visit Role", permissions: [])

  #     # Act
  #     visit admin_role_path(Switch.current_account, visit_role)

  #     # Assert
  #     expect(current_path).to eq(admin_role_path(Switch.current_account, visit_role))
  #   end

  #   scenario "redirects back to account page without permissions" do
  #     # Arrange
  #     role = Role.create(name: "no permissions :(", permissions: [])
  #     user = role.users.create(email: "no@permissions.com")
  #     page.set_rack_session(user_id: user.id)

  #     visit_role = Role.create(name: "Visit Role", permissions: [])

  #     # Act
  #     visit admin_role_path(Switch.current_account, visit_role)

  #     # Assert
  #     expect(current_path).to eq(admin_path(Switch.current_account))
  #   end
  # end

  describe "#new" do
    scenario "can view page with create params" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "create" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      visit new_admin_role_path(Switch.current_account)

      # Assert
      expect(current_path).to eq(new_admin_role_path(Switch.current_account))
    end

    scenario "redirects back to index page without permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      visit new_admin_role_path(Switch.current_account)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end

    scenario "double redirects back to index then account page without any permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      visit new_admin_role_path(Switch.current_account)

      # Assert
      expect(current_path).to eq(admin_path(Switch.current_account))
    end
  end

  describe "#create" do
    scenario "creates with permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [
        { resource: "roles", action: "view" }, { resource: "roles", action: "create" }
      ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act & Assert
      expect {
        page.driver.submit :post, admin_roles_path(Switch.current_account), { role: { name: "Brand New Role" } }
      }.to change(Role, :count).by(1)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end

    scenario "redirects back to index page without permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      # Act
      expect {
        page.driver.submit :post, admin_roles_path(Switch.current_account), { role: { name: "Brand New Role" } }
      }.to change(Role, :count).by(0)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end
  end

  describe "#edit" do
    scenario "can view page with permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [
        { resource: "roles", action: "view" }, { resource: "roles", action: "update" }
      ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Role", permissions: [])

      # Act
      visit edit_admin_role_path(Switch.current_account, visit_role)

      # Assert
      expect(current_path).to eq(edit_admin_role_path(Switch.current_account, visit_role))
    end

    scenario "redirects back to index page without permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Role", permissions: [])

      # Act
      visit edit_admin_role_path(Switch.current_account, role)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end
  end

  describe "#update" do
    scenario "updates with permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [
        { resource: "roles", action: "view" }, { resource: "roles", action: "update" }
      ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Roll", permissions: [])

      # Act
      expect {
        page.driver.submit :patch, admin_role_path(Switch.current_account, visit_role), { role: { name: "Visit Role" } }
      }.to change { visit_role.reload.name }.from("Visit Roll").to("Visit Role")

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end

    scenario "redirects back to index page without permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Roll", permissions: [])

      # Act & Assert
      expect {
        page.driver.submit :patch, admin_role_path(Switch.current_account, visit_role), { role: { name: "Visit Role" } }
      }.not_to change { visit_role.reload.name }

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end
  end

  describe "#destroy" do
    scenario "destroys with permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [
        { resource: "roles", action: "view" }, { resource: "roles", action: "delete" }
      ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Role", permissions: [])

      # Act & Assert
      expect {
        page.driver.submit :delete, admin_role_path(Switch.current_account, visit_role), {}
      }.to change(Role, :count).by(-1)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end

    scenario "redirects back to index page without permissions" do
      # Arrange
      role = Role.create!(name: "no permissions :(", permissions: [ { resource: "roles", action: "view" } ])
      user = role.users.create!(email: "no@permissions.com")
      page.set_rack_session(user_id: user.id)

      visit_role = Role.create(name: "Visit Role", permissions: [])

      # Act & Assert
      expect {
        page.driver.submit :delete, admin_role_path(Switch.current_account, visit_role), {}
      }.to change(Role, :count).by(0)

      # Assert
      expect(current_path).to eq(admin_roles_path(Switch.current_account))
    end
  end
end
