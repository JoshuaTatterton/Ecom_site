class UserMailer < ApplicationMailer
  def sign_up(user)
    @user = user

    mail(to: @user.email,
         content_type: "text/html",
         subject: "Complete Your Sign Up")
  end

  def password_recovery(user)
    @user = user

    mail(to: @user.email,
         content_type: "text/html",
         subject: "Reset Your Password")
  end
end
