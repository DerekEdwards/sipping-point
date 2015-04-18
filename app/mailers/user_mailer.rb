class UserMailer < ActionMailer::Base
  default from: "dedwards8@gmail.com"

  def invite_email(user)
  	@user =  user
  	@url = 'http://www.google.com'
  	mail(to: user.email, subject: "You're Invited.")
  end
end
