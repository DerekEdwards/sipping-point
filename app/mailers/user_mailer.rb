class UserMailer < ActionMailer::Base
  default from: ENV['gmail_username']


  def invite_email(rsvp)
  	@user =  rsvp.user
  	@rsvp = rsvp
  	mail(to: @user.email, subject: "You're Invited.")
  end

  def confirmation_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
  	mail(to: @user.email, subject: "It's on!")
  end 

  def expiration_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
  	mail(to: @user.email, subject:  "Bwah Bwah! :(")
  end
 end 