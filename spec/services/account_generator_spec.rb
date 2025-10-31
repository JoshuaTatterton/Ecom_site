RSpec.describe AccountGenerator, type: :model do
  it "creates the account when providing account information" do
    # Arrange
    generator = AccountGenerator.new(reference: "ecom", name: "Ecom")

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
    generator = AccountGenerator.new(reference: "super_duper_special_awesome_guy")

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
end
