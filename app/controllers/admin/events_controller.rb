class Admin::EventsController < ApplicationController

  before_action :authenticate_user!
  before_action :authorized?

  # GET /events
  # GET /events.json

  def index
    @events = Event.all.order("id DESC")
    @monthly_array = Statistics.new.monthly_array
  end

  def authorized?
    unless current_user.administrator?
      redirect_to root_url
    end
  end

end
