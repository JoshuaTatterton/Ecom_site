RSpec.describe "Admin", type: :system, js: true do
  scenario "can sign in" do
    # Arrange
    visit admin_index_path

    # Act
    within("form[action='/admin/sign_in']") do
      find("input[name='user[email]']").fill_in(with: "example@email.com")
      find("input[name='user[password]']").fill_in(with: "randomlettersandnumbers")
      find("input[type='submit']").click
    end

    # Assert
    aggregate_failures do
      expect(current_path).to eq("/admin")
      expect(page).not_to have_content("Sign in")
    end
  end
end