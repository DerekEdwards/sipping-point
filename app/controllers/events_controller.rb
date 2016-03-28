class EventsController < ApplicationController
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  before_action :set_event, only: [:show, :edit, :update, :destroy, :report, :update_report]
  before_action :authenticate_user!, :except => [:show, :index, :update]  
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
    @excuses = @event.rsvps.said_no.left_excuse

    set_comment_as

    @new_comment = Comment.new()

  end 

  def edit
    set_comment_as
    confirm_invitee
  end

  def new
    @event = Event.new
  
  end

  # POST /events.json
  def create

    logger.info('Create Event')

    params = update_time_params(event_params)
    @event = Event.new(params)

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

    @event.errors.clear    
    confirm_invitee

    old_friends = params.select { |key, value| key.to_s.match(/^!!!email\d+/) }
    old_friends = old_friends.values

    respond_to do |format|
      if @event.invitee_emails_are_valid params[:event][:invitee_emails] and @event.update(event_params)
        @event.description = params[:event][:description]
        @event.create_rsvps_from_ids old_friends
        if params['maximum_attendance'].to_i == -1
          @event.maximum_attendance = nil
        else
          @event.maximum_attendance = params['maximum_attendance'].to_i
        end
        @event.save
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
    
    unless @event.status == Event::CONFIRMED and @event.has_passed?
      redirect_to root_url
    end 
    
    @rsvps = @event.rsvps.said_yes.where("user_id <> ?", @event.owner.id)
  end

  def update_report

    confirm_owner
    @rsvps = @event.rsvps.said_yes
    @rsvps.each do |rsvp|
      unless params[rsvp.user.email].nil?
        # the contents of params[rsvp.user.email] will be based on flake report
        #   Showed Up   =>  1
        #   Flaked      =>  0
        #   No Response => -1
        # NB: No Response attendance reports will be stripped
        if params[rsvp.user.email].to_i == Rsvp::NO_RESPONSE
          rsvp.attendance_report = nil
        else
          rsvp.attendance_report = params[rsvp.user.email].to_i
        end
        rsvp.save
      end
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
      params.require(:event).permit(:name, :owner_email, :threshold, :maximum_attendance, :name, :time, :description, :deadline, :invitee_emails, :location, :open)
    end

    #Set Comment As
    def set_comment_as
      @rsvp_hash_key = params[:rsvp]
      @rsvp = Rsvp.find_by(hash_key: @rsvp_hash_key)
      if @rsvp
        @rsvp.viewed = true
        @rsvp.save 
      end

      if current_user
        @comment_as = current_user
        @rsvp = Rsvp.find_by(event: @event, user: current_user)
        if @rsvp
          @rsvp.viewed = true
          @rsvp.save
        end
      elsif @rsvp_hash_key
        @comment_as = @rsvp.user
      else
        @comment_as = nil
      end

    end

    def confirm_owner
      unless @event.owner == current_user 
        redirect_to root_url
      end     
    end 

    def confirm_invitee
      unless current_user == @event.owner or (current_user and @event.open and current_user.is_invited_to? @event)
        redirect_to root_url
      end
    end

    def send_rsvp_emails
      @event.send_rsvp_emails
    end

    def update_status
      @event.update_status(true)
    end 

    def confirm_editing_rights

    end

    def update_time_params params
      #The input from the new even form retuns the time and time zone as two separate fields
      #This functions creates the time with the correct time zone and then throws away the timeezone field

      Time.zone = params['timezone']
      new_time = Time.zone.parse(params['time'])
      new_deadline = Time.zone.parse(params['deadline'])

      params['time'] = new_time
      params['deadline'] =  new_deadline
      params.delete('timezone')

      return params
    end

end
