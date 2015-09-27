class RsvpsController < ApplicationController
 
 
  def edit
    @rsvp = Rsvp.find_by(hash_key: params[:id])
  end

  def update

    @rsvp = Rsvp.find_by(hash_key: params[:id])
    @rsvp.response = params[:response].to_i
    if @rsvp.response == Event::NO
      @rsvp.wants_comments_emails = false
      @rsvp.excuse = ""
    else
      @rsvp.excuse = params[:excuse]
    end
    @user = @rsvp.user
    @user.name = params[:name]
    @user.save
    @rsvp.save
    @rsvp.event.update_status(send_email=true)

    respond_to do |format|
      format.html { redirect_to event_url(@rsvp.event, rsvp: @rsvp.hash_key) }
    end
  
  end

  def update_email_comments_setting
    rsvp = Rsvp.find_by(hash_key: params[:id])
    email_setting = params[:email_setting]

    if email_setting.downcase == "true"
      email_setting = true
    else
      email_setting = false
    end
    rsvp.wants_comments_emails = email_setting
    rsvp.save

    hash = {email_setting: email_setting}
    render json: hash
  end

  def turn_off_comments
    @rsvp = Rsvp.find_by(hash_key: params[:id])
    @rsvp.wants_comments_emails = false
    @rsvp.save
  end

  def rsvp_reminder
    rsvp = Rsvp.find_by(hash_key: params[:id])
    if (rsvp.reminded  || rsvp.event.created_at) > Time.now - 1.hours
      message = "stop annoying people"
    else
      rsvp.send_rsvp_reminder_email
      message = rsvp.reminded_time_string
    end
    render json: {message: message}
  end

  def hide
    rsvp = Rsvp.find_by(hash_key: params[:id])
    rsvp.hidden = true
    rsvp.save
    render json: {hidden: true}
  end

  def unhide
    rsvp = Rsvp.find_by(hash_key: params[:id])
    rsvp.hidden = false
    rsvp.save
    render json: {hidden: false}
  end
    
end
