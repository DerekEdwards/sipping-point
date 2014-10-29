class Event < ActiveRecord::Base

  belongs_to :owner, :class_name => "User"
  has_many   :rsvps
  has_many   :invitees, through: :rsvps, :source => "User"

  #after_update :is_sipped?

  attr_accessor :owner_email

  protected

  #def is_sipped?
  #  confirmed_users
  #end
end
