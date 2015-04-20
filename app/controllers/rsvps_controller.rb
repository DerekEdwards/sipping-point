class RsvpsController < ApplicationController
 
 
  def edit
    @rsvp = Rsvp.find_by(hash_key: params[:id])
  end

  def update

    @rsvp = Rsvp.find_by(hash_key: params[:id])
    @rsvp.response = params[:rsvp][:response].to_i
    @rsvp.save
    @rsvp.event.update_status

    respond_to do |format|
      format.html { redirect_to @rsvp.event }
    end
  
  end
end
