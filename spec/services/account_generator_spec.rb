RSpec.describe AccountGenerator, :unscoped do
  it "creates the account when providing account information" do
    # Arrange
    generator = AccountGenerator.new(reference: "ecom", name: "Ecom", email: "example@email.co.uk")

    # Act & Assert
    expect {
      expect {
        generator.call!
      }.not_to raise_error
    }.to change(Account, :count).by(1)

    # Assert
    expect(Account.find_by(reference: "ecom", name: "Ecom")).to be_present
  end

  it "auto-generates account name when not provided" do
    # Arrange
    generator = AccountGenerator.new(reference: "super_duper_special_awesome_guy", email: "example@email.co.uk")

    # Act & Assert
    expect {
      expect {
        generator.call!
      }.not_to raise_error
    }.to change(Account, :count).by(1)
    .and change(AccountSetting, :count).by(1)

    # Assert
    aggregate_failures do
      account = Account.find_by(reference: "super_duper_special_awesome_guy")
      expect(account).to be_present
      # Currently set to camelize, could be titleize is wanted
      expect(account.name).to eq("SuperDuperSpecialAwesomeGuy")
      expect(account.account_setting).to be_present
    end
  end

  it "creates an admin Role and User from provided email triggering complete sign up job" do
    # Arrange
    email = "my_user@email.co.uk"
    generator = AccountGenerator.new(reference: "ecom", name: "Ecom", email: email)

    # Act & Assert
    expect {
      expect {
        generator.call!
      }.not_to raise_error
    }.to change(Role.unscoped, :count).by(1)
    .and change(User, :count).by(1)

    # Assert
    aggregate_failures do
      Switch.account("ecom") do
        admin_role = Role.find_by(name: "Admin")
        expect(admin_role.administrator).to eq(true)
        expect(admin_role.users.count).to eq(1)

        created_user = User.find_by(email: email)
        expect(created_user.awaiting_authentication).to eq(true)
        expect(created_user.role).to eq(admin_role)

        expect(UserSignUpJob).to have_enqueued_sidekiq_job(created_user.id)
        expect(UserSignUpJob.jobs.dig(0, "account_reference")).to eq("ecom")
      end
    end
  end

  it "creates an admin Role and attaches to an existing user, doesn't trigger sign up job" do
    # Arrange
    email = "my_user@email.co.uk"
    user = User.create(email: email)
    generator = AccountGenerator.new(reference: "ecom", name: "Ecom", email: email)

    # Act & Assert
    expect {
      expect {
        generator.call!
      }.not_to raise_error
    }.to change(Role.unscoped, :count).by(1)
    .and change(User, :count).by(0)

    # Assert
    aggregate_failures do
      Switch.account("ecom") do
        admin_role = Role.find_by(name: "Admin")
        expect(admin_role.administrator).to eq(true)
        expect(admin_role.users.count).to eq(1)

        expect(user.reload.role).to eq(admin_role)

        expect(UserSignUpJob).not_to have_enqueued_sidekiq_job
      end
    end
  end
end
