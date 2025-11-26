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

  describe "#create", unscoped: true do
    context "with a valid email" do
      context "for an authorised user" do
        it "can trigger password recovery" do
          # Arrange
          user = nil
          Switch.account("primary") {
            role = Role.create(name: "Sweet Role")
            user = role.users.create(
              email: "test@user.com",
              name: "Test",
              password: "SuperSecretPassword",
              awaiting_authentication: false
            )
          }

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
            user = nil
            Switch.account("primary") {
              role = Role.create(name: "Sweet Role")
              user = role.users.create(email: "test@user.com")
            }

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
              expect(UserSignUpJob.jobs.dig(0, "account_reference")).to eq("primary")
            end
          end
        end

        context "without an account membership" do
          it "triggers account unscoped sign up job" do
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

    context "with an invalid email" do
      it "redirects successfully without triggering anything" do
        # Arrange
        visit admin_password_recovery_index_path

        # Act
        within("form[action='#{admin_password_recovery_index_path}']") do
          find("input[name='user[email]']").fill_in(with: "invalid@email.com")

          find("input[type='submit']").click
        end

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_index_path)

          expect(PasswordRecoveryJob).not_to have_enqueued_sidekiq_job
          expect(UserSignUpJob).not_to have_enqueued_sidekiq_job
        end
      end
    end
  end
end
