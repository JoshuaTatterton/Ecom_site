RSpec.describe "User Edit Admin", type: :system do
  describe "#index" do
    context "while signed in" do
      it "shows the sign up form" do
        # Act
        visit admin_index_path

        within(".navbar") do
          find("#user_nav").click
          find("a#user_edit").click
        end

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_edit_index_path)

          within("form[action='#{admin_edit_index_path}']") do
            expect(page).to have_selector("input[name='user[name]'][value='#{@primary_user.name}']")
          end
        end
      end
    end

    context "while signed out", signed_out: true do
      it "redirects to the login page" do
        # Act
        visit admin_edit_index_path

        # Assert
        aggregate_failures do
          expect(current_path).to eq(admin_index_path)
        end
      end
    end
  end

  describe "#create" do
    it "can update user" do
      # Arrange
      visit admin_edit_index_path

      new_name = "My Name"

      # Act
      within("form[action='#{admin_edit_index_path}']") do
        find("input[name='user[name]']").fill_in(with: new_name)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_index_path)

        expect(@primary_user.reload.name).to eq(new_name)
      end
    end

    it "re-renders form if update fails" do
      # Arrange
      visit admin_edit_index_path

      new_name = ""

      # Act
      within("form[action='#{admin_edit_index_path}']") do
        find("input[name='user[name]']").fill_in(with: new_name)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(current_path).to eq(admin_edit_index_path)

        expect(@primary_user.reload.name).not_to eq(new_name)
      end
    end
  end
end
