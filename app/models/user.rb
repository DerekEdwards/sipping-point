class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable,  :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable, :validatable
 
  #Relationships
  has_many :events, foreign_key: "owner_id", class_name: "Event"
  has_many :rsvps
  has_many :unfriendships
  has_many :unfriends, through: :unfriendships

  #Validations
  validates_uniqueness_of :email

  #Scopes
  scope :confirmed, -> { where("confirmed = ?", true) }

  #people that you have invited in the past or that have invited you
  def my_people
    my_people = []

    my_events = Event.where(owner: self)
    my_events.each do |event|
      rsvps = event.rsvps
      rsvps.each do |rsvp|
        unless rsvp.user.nil? or rsvp.user.in? my_people or rsvp.user == self or rsvp.user.in? self.unfriends
          my_people << rsvp.user
        end
      end
    end

    my_rsvps = Rsvp.where(user: self)
    my_rsvps.each do |rsvp|
      unless rsvp.user.nil? or rsvp.event.owner.in? my_people or rsvp.user == self or rsvp.user.in? self.unfriends
        my_people << rsvp.event.owner
      end
    end

    my_people.sort_by{|p| p[:email]}

  end
   
  def flake_factor 
    reports = self.rsvps.reported
    flakes = reports.flaked

    unless reports.count == 0
      return flakes.count.to_f/reports.count.to_f
    else
      return nil
    end 
  end

  def reliability_factor
    flakiness = flake_factor
    if flakiness
      return 1.0 - flake_factor
    else
      return nil
    end
  end

  def is_invited_to? event
    self.in? event.invitees
  end 

  ######### Statistics Methods #######
  
  #Average number of confirmed RSVPs for events that this user plans
  def average_rsvp_yes_count
    rsvp_count = 0
    my_events = self.events.confirmed
    my_events.each do |event|
      rsvp_count += event.rsvps.said_yes.count 
    end

    rsvp_count.to_f/my_events.count.to_f
  end

  def percent_yes
    total_rsvps = self.rsvps.count
    said_yes = self.rsvps.said_yes.count
    return (said_yes.to_f/total_rsvps.to_f)*100
  end

  def percent_no
    total_rsvps = self.rsvps.count
    said_no = self.rsvps.said_no.count
    return (said_no.to_f/total_rsvps.to_f)*100
  end

  def percent_none
    return 100 - percent_no - percent_yes
  end

  ######### End Statistics Methods ###


  ########## String Generators #######

  def display_name
    if self.name.nil? or self.name.blank?
      return self.email
    else
      return self.name
    end
  end

  def to_s
    name || email
  end

  def reliability
    if self.reliability_factor
      return (reliability_factor * 100).round.to_s + "%"
    else
      return ""
    end
  end

  #Gmail doesn't like people with 1 name.  If a person has only
  #1 Name, set the from to the Sipping Point stead of the name
  def email_name
    if self.display_name.split(' ').count == 1
      return "Sipping Point"
    else
      return self.name
    end
  end

  ########## End String Generators #######


end
