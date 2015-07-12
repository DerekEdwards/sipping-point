class UserMailer < ActionMailer::Base

  #Send invitations
  def invite_email(rsvp)
  	@user =  rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: "You're invited to " + @event.name, from: @event.owner.email_name)
  end

  #Reminder to attend
  def reminder_email(rsvp)
    @user =  rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    mail(to: @user.email, subject: "Reminder about " + @event.name, from: @event.owner.email_name)
  end

  #Let people know the event is officially on
  def confirmation_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " is Happening!", from: @event.owner.email_name)
  end 

  #Let people know the event failed
  def expiration_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " is canceled", from: @event.owner.email_name)
  end

  #Notice that new comments have been made
  def comments_email(rsvp, comments)
    @user = rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    @comments = comments
    mail(to: @user.email, subject: "Someone left a comment on " + @event.name, from: @event.owner.email_name)
  end

  #Email sent to owner to report flakes
  def report_email(event)
    @event = event
    mail(to: @event.owner.email, subject: "Who flaked on " + @event.name + "?", from: @event.owner.email_name)
  end

  #Reminder to RSVP
  def rsvp_reminder_email(rsvp)
    @rsvp = rsvp
    @event = rsvp.event
    @user = rsvp.user
    mail(to: @rsvp.user.email, subject: "Don't forget to RSVP for " + @rsvp.event.name, from: @rsvp.event.owner.email_name)
  end
end 