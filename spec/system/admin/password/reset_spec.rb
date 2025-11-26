RSpec.describe "Password Reset Admin", type: :system, signed_out: true do
  describe "#index" do
    context "when a valid token is present" do
      it "shows the password reset form" do
        # Arrange
        user = User.create(email: "test@user.com")

        # Act
        visit admin_password_reset_index_path(token: user.password_reset_token)

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_password_reset_index_path)
          within("form[action='#{admin_password_reset_index_path}']") do
            expect(page).to have_selector("input[name='user[password]']")
            expect(page).to have_selector("input[name='user[password_confirmation]']")
          end
        end
      end
    end

    context "when an invalid token is present" do
      it "redirects to admin page" do
        # Arrange
        user = User.create(email: "test@user.com")

        # Act
        visit admin_password_reset_index_path(token: user.authentication_password_reset_token)

        # Assert
        expect(current_path).to eq(admin_index_path)
      end
    end

    context "when signed in as a user", signed_out: false do
      it "redirects to admin page" do
        # Arrange
        user = User.create(email: "test@user.com")

        # Act
        visit admin_password_reset_index_path(token: user.authentication_password_reset_token)

        # Assert
        expect(current_path).to eq(admin_index_path)
      end
    end
  end

  describe "#create" do
    it "can complete password reset" do
      # Arrange
      old_password = "OLDPASSWORD"
      user = User.create(
        email: "test@user.com",
        name: "This Guy",
        password: old_password,
        awaiting_authentication: false
      )

      visit admin_password_reset_index_path(token: user.password_reset_token)

      password = "SuperSecretPassword"

      # Act
      within("form[action='#{admin_password_reset_index_path}']") do
        find("input[name='user[password]']").fill_in(with: password)
        find("input[name='user[password_confirmation]']").fill_in(with: password)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)

        expect(user.reload.authenticate(password)).to eq(user)
        expect(user.authenticate(old_password)).to eq(false)
      end
    end

    it "re-renders form if passwords fail" do
      # Arrange
      old_password = "OLDPASSWORD"
      user = User.create(
        email: "test@user.com",
        name: "This Guy",
        password: old_password,
        awaiting_authentication: false
      )

      visit admin_password_reset_index_path(token: user.password_reset_token)

      password = "SuperSecretPassword"

      # Act
      within("form[action='#{admin_password_reset_index_path}']") do
        find("input[name='user[password]']").fill_in(with: password)
        find("input[name='user[password_confirmation]']").fill_in(with: "#{password}1")

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_password_reset_index_path)

        expect(user.reload.authenticate(old_password)).to eq(user)
        expect(user.authenticate(password)).to eq(false)
      end
    end

    it "redirects if user from token not found" do
      # Arrange
      old_password = "OLDPASSWORD"
      user = User.create(
        email: "test@user.com",
        name: "This Guy",
        password: old_password,
        awaiting_authentication: false
      )

      page.set_rack_session(auth_user_id: "FakeID")

      password = "SuperSecretPassword"

      # Act
      # Using driver submit to test malicious behaviour
      page.driver.submit :post, admin_password_reset_index_path, {
        user: {
          password: password,
          password_confirmation: password
        }
      }

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)

        expect(user.reload.authenticate(old_password)).to eq(user)
        expect(user.authenticate(password)).to eq(false)
      end
    end
  end
end
