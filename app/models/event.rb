class Event < ActiveRecord::Base

  #Relationships
  belongs_to :owner, :class_name => "User"
  has_many   :rsvps
  has_many   :invitees, through: :rsvps, :source => "User"

  #Accessors
  attr_accessor :owner_email
  attr_accessor :invitee_emails

  #Validations
  validates :hash_key, uniqueness: true
  validates_presence_of :name
  validate :maximum_is_not_less_than_sipping_point
  validate :rsvp_deadline_is_before_event

  #Constants
  INITIALIZED = 'initalized'
  OPEN = 'open'
  EXPIRED = 'expired'
  CONFIRMED = 'confirmed'
  FULL = 'max_attendance_reached'

  #Scopes
  scope :open, -> { where(status:Event::OPEN) }
  scope :deadline_passed, -> { where("deadline < ?", DateTime.now) }
  scope :upcoming, -> { where("time >= ?", Time.now - 2*3600) }

  #Commentable
  acts_as_commentable

  #Methods
  def to_param
    self.hash_key
  end 
  ########## String Generators ###########
  def html_description
    self.description.gsub("\n", "<br>")
  end

  def display_time
    display self.time
  end

  def display_time_wordy
    display_wordy self.time
  end

  def display_deadline
    display self.deadline
  end

  def display_deadline_wordy
    display_wordy self.deadline
  end

  def display time
    #If time is not this year AND the month is more than 90 days away from now
    if(time.year - Time.now.year).abs > 0 and (time - Time.now).abs > 3*30*24*3600
      time.strftime("%a, %b %d, %Y %l:%M %p").gsub("  ", " ")
    else
     time.strftime("%a, %b %d %l:%M %p").gsub("  ", " ")
    end
  end 

  def display_wordy time
    #If time is not this year AND the month is more than 90 days away from now
    if(time.year - Time.now.year).abs > 0 and (time - Time.now).abs > 3*30*24*3600
      time.strftime("%A, %B %d, %Y at %l:%M %p").gsub("  ", " ")
    else
     time.strftime("%A, %B %d at %l:%M %p").gsub("  ", " ")
    end
  end

  def yes_count_phrase
    yes_count = self.rsvps.said_yes.count
    if yes_count == 0
      return "no one has"
    elsif yes_count == 1
      return "1 person has"
    else
      return yes_count.to_s + " people have"
    end
  end

  ####### END STRING GENERATORS #######

  def has_max_attendance?
    maximum_attendance.present?
  end

  def has_spots_remaining?
    has_max_attendance? && (maximum_attendance > rsvps.said_yes.count)
  end

  def is_full_up?
    !has_spots_remaining?
  end

  def percent_complete
    ([self.rsvps.said_yes.count.to_f/self.threshold,1].min)*100
  end    

  def rsvps_needed
    [(self.threshold - self.rsvps.said_yes.count), 0].max
  end

  def invitee_emails=(value)

    create_owner_rsvp

  	emails = value.split(',')
  	emails.each do |email|
      unless email.blank?
    	  user = User.find_or_create_by(email: email.strip.downcase) do |u|
          u.password = u.password_confirmation =Devise.friendly_token.first(8)
        end

        rsvp = Rsvp.where(user: user, event: self).first_or_create
        rsvp.emailed = false
        rsvp.new_record?
        rsvp.generate_hash_key
        rsvp.save!
      end
    end 
  end

  def generate_hash_key

    if self.hash_key
      return self.hash_key
    else
      hash_key = Digest::MD5.hexdigest(self.name + self.owner.email + DateTime.now.to_s + rand.to_s)
      self.hash_key = hash_key
      self.save
      return hash_key 
    end
  
  end

  def update_status send_email=false
    if deadline < DateTime.now # if the deadline passed, finalize the event
      if self.status != Event::EXPIRED and send_email
        send_expiration_emails
      end
      self.status = Event::EXPIRED
    else # otherwise, set up the status appropriately

      if self.rsvps.count == 0 # The event has been created
        self.status = Event::INITIALIZED
      elsif self.rsvps.said_yes.count >= self.threshold  # The event is on!
        send_confirmation_emails if (self.status != Event::CONFIRMED and send_email)
        self.status = Event::CONFIRMED
      elsif self.is_full_up?
        self.status = Event::FULL
      else # The event is awaiting RSVPs
        self.status = Event::OPEN
      end
    end

    self.save

    return self.status 
  end

  def create_owner_rsvp
    Rsvp.where(user: self.owner, event: self).first_or_create do |rsvp|
      rsvp.generate_hash_key
      rsvp.save!
    end
  end

  def send_confirmation_emails
    sendable_rsvps = self.rsvps.said_yes + self.rsvps.unanswered
    sendable_rsvps.each do |rsvp|
      UserMailer.confirmation_email(rsvp).deliver!
    end
  end   

  def send_expiration_emails
    sendable_rsvps = self.rsvps.said_yes + self.rsvps.unanswered
    sendable_rsvps.each do |rsvp|
      UserMailer.expiration_email(rsvp).deliver!
    end
  end 

  def send_rsvp_emails
    self.rsvps.each do |rsvp|
      unless rsvp.emailed?
        UserMailer.invite_email(rsvp).deliver!
        rsvp.emailed = true
        rsvp.save
      end
    end
  end  

  def send_comments_emails
    comments = new_comments
    if comments.count > 0
      self.rsvps.wants_comments_emails.each do |rsvp|
        UserMailer.comments_email(rsvp, comments).deliver!
      end
      self.comments_last_mailed = comments.last.created_at
      self.save
    end
  end

  def invitee_emails
  	nil
  end

  def short_description
    case self.status
    when Event::OPEN
      return "Waiting for RSVPs" 
    when Event::INITIALIZED
      return "Invitations not Sent"
    when Event::EXPIRED
      return "Not Happening"
    when Event::FULL
      return "All Full Up"
    when Event::CONFIRMED
      return "It's On!"
    end
  end

  def new_comments
    self.comment_threads.where("created_at > ?", self.comments_last_mailed || self.created_at).order('created_at')
  end

  def invitee_emails_are_valid emails
    
    if emails.blank?
      return true
    end 
    emails = emails.split(',')
    emails.each do |email|
      unless email.blank?
        unless valid_email(email.strip.downcase)
          puts 'testing ' + email
          errors.add(:invitee_emails, email + " is not a valid email.")
          return false
        end
      end
    end 
  end

  private

  ### Custom Validations
  def rsvp_deadline_is_before_event
    if deadline > time
      errors.add(:deadline, " must be before the event starts")
    end
  end

  def maximum_is_not_less_than_sipping_point
    if maximum_attendance and maximum_attendance < threshold
      errors.add(:maximum_attendance, " can't be lower than the sipping point")
    end
  end

  def valid_email(email)
    return email=~/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  end

end
