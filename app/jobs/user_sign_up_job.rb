class UserSignUpJob
  include Sidekiq::Job

  def perform(membership_id)
    membership = Membership.find(membership_id)
    user = membership.user

    if user.awaiting_authentication
      user.update(authentication_password: SecureRandom.uuid)

      UserMailer.sign_up(user).deliver_now
    end
  end
end
