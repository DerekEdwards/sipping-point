class Event < ActiveRecord::Base

  belongs_to :owner, :class => "User"
  has_many   :rsvps
  has_many   :invitees, through: :rsvps, :source => "User"

  after_update :is_sipped?








  protected

  def is_sipped?
    confirmed_users
  end
end
