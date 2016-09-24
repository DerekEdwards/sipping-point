class UserMailer < ActionMailer::Base

  #Send invitations
  def invite_email(rsvp)
  	@user =  rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name, from: ENV['smtp_from'])
  end

  #Reminder to attend
  def reminder_email(rsvp)
    @user =  rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    mail(to: @user.email, subject: "Reminder about " + @event.name, from: ENV['smtp_from'])
  end

  #Let people know the event is officially on
  def confirmation_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " is Happening!", from: ENV['smtp_from'])
  end 

  #Let people know the event failed
  def expiration_email(rsvp)
  	@user = rsvp.user
  	@rsvp = rsvp
    @event = rsvp.event
  	mail(to: @user.email, subject: @event.name + " Failed to Reach the Sipping Point", from: ENV['smtp_from'])
  end

  #Notice that new comments have been made
  def comments_email(rsvp, comments)
    @user = rsvp.user
    @rsvp = rsvp
    @event = rsvp.event
    @comments = comments
    if @comments.count == 0
      mail(to: @user.email, subject: "New comment on " + @event.name, from: ENV['smtp_from'])
    else
      mail(to: @user.email, subject: "New comments on " + @event.name, from: ENV['smtp_from'])
    end
  end

  #Email sent to owner to report flakes
  def report_email(event)
    @event = event
    mail(to: @event.owner.email, subject: "Who flaked on " + @event.name + "?", from: ENV['smtp_from'])
  end

  #Reminder to RSVP
  def rsvp_reminder_email(rsvp)
    @rsvp = rsvp
    @event = rsvp.event
    @user = rsvp.user
    mail(to: @rsvp.user.email, subject: "Don't forget to RSVP for " + @rsvp.event.name, from: ENV['smtp_from'])
  end
end 