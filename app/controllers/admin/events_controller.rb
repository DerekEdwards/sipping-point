class Admin::EventsController < ApplicationController

  before_action :authenticate_user!
  before_action :authorized?

  # GET /events
  # GET /events.json

  def index
    @events = Event.all.order("id DESC")
  end

  def authorized?
    unless current_user.administrator?
      redirect_to root_url
    end
  end

end
