class UserSignUpJob
  include Sidekiq::Job

  def perform(membership_id)
    puts "YOOooooo #{Switch.current_account.inspect} #{membership_id}"
    membership = Membership.find(membership_id)
    user = membership.user
    user.update(authentication_password: SecureRandom.uuid)

    UserMailer.sign_up(user).deliver_now
  end
end
