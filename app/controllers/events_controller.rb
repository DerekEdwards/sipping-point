class EventsController < ApplicationController
  
  before_action :set_event, only: [:show, :edit, :update, :destroy]
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
    owner_email = params[:event][:owner_email] 
    
    @event.owner = current_user
    @event.generate_hash_key
    @event.update_status

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
    
    confirm_owner

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

    confirm_owner

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
      params.require(:event).permit(:name, :owner_email, :threshold, :name, :time, :description, :deadline, :invitee_emails, :location )
    end

    def confirm_owner
      unless @event.owner == current_user 
        redirect_to root_url
      end     
    end 

    def update_status
      @event.update_status
    end 
end
