class RsvpsController < ApplicationController
 
 
  def edit
    @rsvp = Rsvp.find_by(hash_key: params[:id])
  end

  def update

    @rsvp = Rsvp.find_by(hash_key: params[:id])
    @rsvp.response = params[:response].to_i
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
end
