class Event < ActiveRecord::Base

  belongs_to :owner, :class => "User"
end
