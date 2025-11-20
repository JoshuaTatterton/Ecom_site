class PasswordRecoveryJob
  include Sidekiq::Job

  def perform(user_id)
    # user = User.find(id)

    # if user.awaiting_authentication
    #   user.update!(authentication_password: SecureRandom.uuid)

    #   UserMailer.sign_up(user).deliver_now
    # end
  end
end
