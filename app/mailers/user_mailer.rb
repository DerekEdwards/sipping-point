class UserMailer < ActionMailer::Base

  def invite_email(rsvp)
  	@user =  rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: "You're invited to " + @event.name, from: @event.owner.email_name)
  end

  def reminder_email(rsvp)
    @user =  rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    mail(to: @user.email, subject: "Reminder about " + @event.name, from: @event.owner.email_name)
  end

  def confirmation_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " is Happening!", from: @event.owner.email_name)
  end 

  def expiration_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " is canceled", from: @event.owner.email_name)
  end

  def comments_email(rsvp, comments)
    @user = rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    @comments = comments
    mail(to: @user.email, subject: "Someone left a comment on " + @event.name, from: @event.owner.email_name)
  end

  def report_email(event)
    @event = event
    mail(to: @event.owner.email, subject: "Who flaked on " + @event.name + "?", from: @event.owner.email_name)
  end

 end 