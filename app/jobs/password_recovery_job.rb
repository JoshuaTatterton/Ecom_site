class PasswordRecoveryJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find(user_id)

    UserMailer.password_recovery(user).deliver_now
  end
end
