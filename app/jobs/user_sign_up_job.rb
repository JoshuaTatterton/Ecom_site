class UserSignUpJob
  include Sidekiq::Job

  def perform(membership_id)
    puts "YOOooooo #{Switch.current_account.inspect} #{membership_id}"
  end
end
