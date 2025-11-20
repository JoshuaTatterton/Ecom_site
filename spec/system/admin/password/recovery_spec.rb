RSpec.describe "Password Recovery Admin", type: :system, signed_out: true do
  describe "#index" do
    context "when not signed in" do
      it "shows the password recovery form" do
        # Arrange
        visit admin_index_path

        # Act
        find("[href='#{admin_password_recovery_index_path}']").click

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_password_recovery_index_path)
          within("form[action='#{admin_password_recovery_index_path}']") do
            expect(page).to have_selector("input[name='user[email]']")
          end
        end
      end
    end

    context "when an signed in as a user", signed_out: false do
      it "redirects to admin page" do
        # Act
        visit admin_password_recovery_index_path

        # Assert
        expect(current_path).to eq(admin_index_path)
      end
    end
  end

  describe "#create" do
    context "with a valid email" do
      context "for an authorised user" do
        it "can trigger password recovery" do
          # Arrange
          role = Role.create(name: "Sweet Role")
          user = role.users.create(
            email: "test@user.com",
            name: "Test",
            password: "SuperSecretPassword",
            awaiting_authentication: false
          )

          visit admin_password_recovery_index_path

          # Act
          within("form[action='#{admin_password_recovery_index_path}']") do
            find("input[name='user[email]']").fill_in(with: user.email)

            find("input[type='submit']").click
          end

          # Assert
          aggregate_failures do
            expect(current_path).to eq(admin_index_path)

            expect(PasswordRecoveryJob).to have_enqueued_sidekiq_job(user.id)
          end
        end
      end

      context "for a user awaiting authorisation" do
        context "with an account membership" do
          it "triggers sign up job" do
            # Arrange
            role = Role.create(name: "Sweet Role")
            user = role.users.create(email: "test@user.com")
            membership = user.membership

            visit admin_password_recovery_index_path

            # Act
            within("form[action='#{admin_password_recovery_index_path}']") do
              find("input[name='user[email]']").fill_in(with: user.email)

              find("input[type='submit']").click
            end

            # Assert
            aggregate_failures do
              expect(current_path).to eq(admin_index_path)

              expect(UserSignUpJob).to have_enqueued_sidekiq_job(user.id)
              puts UserSignUpJob.jobs.dig(0)
              expect(UserSignUpJob.jobs.dig(0, "account_reference")).to eq(Switch.current_account)
            end
          end
        end

        context "without an account membership" do
          it "triggers sign up job" do
            # Arrange
            user = User.create(email: "test@user.com")

            visit admin_password_recovery_index_path

            # Act
            within("form[action='#{admin_password_recovery_index_path}']") do
              find("input[name='user[email]']").fill_in(with: user.email)

              find("input[type='submit']").click
            end

            # Assert
            aggregate_failures do
              expect(current_path).to eq(admin_index_path)

              expect(UserSignUpJob).to have_enqueued_sidekiq_job(user.id)
              expect(UserSignUpJob.jobs.dig(0, "account_reference")).to eq(nil)
            end
          end
        end
      end
    end

    # it "redirects if user is already authenticated" do
    #   # Arrange
    #   role = Role.create(name: "Sweet Role")
    #   user = role.users.create(
    #     email: "test@user.com",
    #     name: "Old Name",
    #     password: "SuperSecretPassword",
    #     awaiting_authentication: false
    #   )
    #   page.set_rack_session(auth_user_id: user.id)

    #   # Act
    #   # Using driver submit to test malicious behaviour
    #   page.driver.submit :post, admin_sign_up_index_path, {
    #     user: {
    #       name: "New Name",
    #       password: "SuperSecretPassword",
    #       password_confirmation: "SuperSecretPassword"
    #     }
    #   }

    #   # Assert
    #   aggregate_failures do
    #     expect(current_path).to eq(admin_index_path)

    #     expect(user.reload.name).to eq("Old Name")
    #   end
    # end
  end
end
