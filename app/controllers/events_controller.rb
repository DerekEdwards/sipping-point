class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  # GET /events
  # GET /events.json

  def index
    logger.info("Index Event")
    @events = Event.all
    @event = Event.new
  end

  # GET /events/1
  # GET /events/1.json
  def show
  
  end 

  def edit

  end

  def new
  
  end

  # POST /events.json
  def create
    logger.info('Create Event')
    @event = Event.new(event_params)
    owner_email = params[:event][:owner_email] 

    #If this is the first time for this user, create a new user account
    user = User.where(email: owner_email).first_or_create
    
    #We currently don't use fully fledged user accounts.  This is a placeholder for if/when we do.
    user.password = "sippingpoint"
    user.password_confirmation = "sippingpoint"
    user.save 
    
    @event.owner = user
    @event.generate_hash_key

    respond_to do |format|
      if @event.save
        format.html { redirect_to event_path(@event), notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update

    respond_to do |format|
      if @event.update(event_params)
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

    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find_by(hash_key: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:name, :owner_email, :threshold, :name, :time, :description, :deadline, :invitee_emails )
    end
  
end
