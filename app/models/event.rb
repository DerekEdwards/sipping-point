class Event < ActiveRecord::Base

  has_one :organizer, :class => "User"
end
