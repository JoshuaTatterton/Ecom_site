require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  it "" do
    visit "rails/mailers/user_mailer"

    email = UserMailer.create_invite(User.first)
  end
end
