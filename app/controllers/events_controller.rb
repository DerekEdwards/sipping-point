class EventsController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :set_event, only: [:show, :edit, :update, :destroy, :report, :update_report]
  before_action :authenticate_user!, :except => [:show, :index]  
  after_action  :update_status, only: [:create, :show, :update, :destroy]

  # GET /events
  # GET /events.json

  def index
    logger.info("Index Event")
    @events = Event.where(owner: current_user)
    @event = Event.new
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @comments = @event.comment_threads.order('created_at')
    @rsvp_hash_key = params[:rsvp]
    @rsvp = Rsvp.find_by(hash_key: @rsvp_hash_key)
    
    if current_user
      @comment_as = current_user
      @rsvp = Rsvp.find_by(event: @event, user: current_user)
    elsif @rsvp_hash_key
      @comment_as = @rsvp.user
    else
      @comment_as = nil
    end

    @new_comment = Comment.new()

  end 

  def edit
    confirm_owner
  end

  def new
    @event = Event.new
  
  end

  # POST /events.json
  def create

    logger.info('Create Event')
    @event = Event.new(event_params)
    
    @event.owner = current_user
    @event.generate_hash_key
    @event.update_status

    respond_to do |format|
      if @event.save
        format.html { redirect_to edit_event_path(@event), notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  def update
    
    confirm_owner

    respond_to do |format|
      if @event.invitee_emails_are_valid params[:event][:invitee_emails] and @event.update(event_params)
        @event.description = (sanitize(simple_format(params[:event][:description]))).gsub("<p>","").gsub("</p>","")
        @event.send_rsvp_emails 
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy

    confirm_owner

    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def report
    confirm_owner
    @rsvps = @event.rsvps.said_yes
  end

  def update_report

    confirm_owner

    @rsvps = @event.rsvps.said_yes
    @rsvps.each do |rsvp|
      rsvp.attendance_report = params[rsvp.user.email].to_i
      rsvp.save
    end 

    respond_to do |format|
      format.html { redirect_to @event, notice: 'Thanks for submitting your Flake Report.' }
      format.json { render :show, status: :ok, location: @event }
    end

  end

  def caltest
    respond_to do |format|
      format.html {render :caltest, :layout => false}
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by(hash_key: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :owner_email, :threshold, :maximum_attendance, :name, :time, :description, :deadline, :invitee_emails, :location)
    end

    def confirm_owner
      unless @event.owner == current_user 
        redirect_to root_url
      end     
    end 

    def send_rsvp_emails
      @event.send_rsvp_emails
    end

    def update_status
      @event.update_status(true)
    end 
end
