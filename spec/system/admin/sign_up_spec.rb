RSpec.describe "User Sign Up Admin", type: :system, signed_out: true do
  describe "#index" do
    context "when a valid token is present" do
      it "shows the sign up form" do
        # Arrange
        role = Role.create(name: "Sweet Role")
        user = role.users.create(email: "test@user.com")

        # Act
        visit admin_sign_up_index_path(token: user.authentication_password_reset_token)

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_sign_up_index_path)
          within("form[action='#{admin_sign_up_index_path}']") do
            expect(page).to have_selector("input[name='user[name]']")
            expect(page).to have_selector("input[name='user[password]']")
            expect(page).to have_selector("input[name='user[password_confirmation]']")
          end
        end
      end

      context "user for token is already authenticated" do
        it "redirects to admin page" do
          # Arrange
          role = Role.create(name: "Sweet Role")
          user = role.users.create(
            email: "test@user.com",
            name: "Test",
            password: "SuperSecretPassword",
            awaiting_authentication: false
          )

          # Act
          visit admin_sign_up_index_path(token: user.authentication_password_reset_token)

          # Assert
          expect(current_path).to eq(admin_index_path)
        end
      end
    end

    context "when an invalid token is present" do
      it "redirects to admin page" do
        # Arrange
        role = Role.create(name: "Sweet Role")
        user = role.users.create(email: "test@user.com")

        # Act
        visit admin_sign_up_index_path(token: user.password_reset_token)

        # Assert
        expect(current_path).to eq(admin_index_path)
      end
    end

    context "when a signed in as a user", signed_out: false do
      it "redirects to admin page" do
        # Arrange
        role = Role.create(name: "Sweet Role")
        user = role.users.create(email: "test@user.com")

        # Act
        visit admin_sign_up_index_path(token: user.authentication_password_reset_token)

        # Assert
        expect(current_path).to eq(admin_index_path)
      end
    end
  end

  describe "#create" do
    it "can complete sign up" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(email: "test@user.com")

      visit admin_sign_up_index_path(token: user.authentication_password_reset_token)

      name = "My Name"
      password = "SuperSecretPassword"

      # Act
      within("form[action='#{admin_sign_up_index_path}']") do
        find("input[name='user[name]']").fill_in(with: name)
        find("input[name='user[password]']").fill_in(with: password)
        find("input[name='user[password_confirmation]']").fill_in(with: password)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_path(Switch.current_account))

        expect(user.reload.awaiting_authentication).to eq(false)
        expect(user.name).to eq(name)
        expect(user.authenticate(password)).to eq(user)
      end
    end

    it "redirects if user is already authenticated" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(
        email: "test@user.com",
        name: "Old Name",
        password: "SuperSecretPassword",
        awaiting_authentication: false
      )
      page.set_rack_session(auth_user_id: user.id)

      # Act
      # Using driver submit to test malicious behaviour
      page.driver.submit :post, admin_sign_up_index_path, {
        user: {
          name: "New Name",
          password: "SuperSecretPassword",
          password_confirmation: "SuperSecretPassword"
        }
      }

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)

        expect(user.reload.name).to eq("Old Name")
      end
    end

    it "redirects if user not found" do
      # Arrange
      role = Role.create(name: "Sweet Role")
      user = role.users.create(
        email: "test@user.com",
        name: "Old Name",
        password: "SuperSecretPassword",
        awaiting_authentication: false
      )
      page.set_rack_session(auth_user_id: "fakeID")

      # Act
      # Using driver submit to test malicious behaviour
      page.driver.submit :post, admin_sign_up_index_path, {
        user: {
          name: "New Name",
          password: "SuperSecretPassword",
          password_confirmation: "SuperSecretPassword"
        }
      }

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)

        expect(user.reload.name).to eq("Old Name")
      end
    end
  end
end
