class Event < ActiveRecord::Base

  #Relationships
  belongs_to :owner, :class_name => "User"
  has_many   :coming_rsvps, -> {where(response: Rsvp::YES)}, class_name: 'Rsvp',
                after_add: :update_is_tipped,
                before_remove: :update_is_tipped
  has_many   :rsvps
  has_many   :invitees, through: :rsvps, :source => :user

  #Accessors
  attr_accessor :owner_email
  attr_accessor :invitee_emails

  #Validations
  validates :hash_key, uniqueness: true
  validates_presence_of :name
  validate :maximum_is_not_less_than_sipping_point
  #These validations will prevent event statuses from being updated
  #validate :event_time_not_in_past
  #validate :rsvp_deadline_not_in_past
  validate :rsvp_deadline_is_before_event

  #Constants
  INITIALIZED = 'initalized'
  OPEN = 'open'
  EXPIRED = 'expired'
  CONFIRMED = 'confirmed'

  #Scopes
  scope :open, -> { where(status:Event::OPEN) }
  scope :confirmed, -> { where(status:Event::CONFIRMED) }
  scope :deadline_passed, -> { where("deadline < ?", DateTime.now) }
  scope :upcoming, -> { where("time >= ?", Time.now - 2*3600) }
  scope :ready_for_report, -> { where("time <= ? and report_sent = false and status = ?", Time.now - 6*3600, Event::CONFIRMED)}
  scope :happening_within_24hrs, -> { where("time >= ? and time < ?", Time.now, Time.now + 24*3600)}
  scope :deadline_not_passed, -> { where("deadline >= ?", Time.now) }
  scope :not_expired, -> { where("status <> ?", Event::EXPIRED)}
  scope :tipped, -> { where(is_tipped: true)}

  #Commentable
  acts_as_commentable

  #Methods
  def to_param
    self.hash_key
  end 

  def has_max_attendance?
    maximum_attendance.present?
  end

  def has_spots_remaining?
    unless has_max_attendance?
      return true
    else
      return (maximum_attendance > rsvps.said_yes.count)
    end
  end

  def is_full_up?
    !has_spots_remaining?
  end

  def tipped? 
    if threshold
      return coming_rsvps.count >= threshold
    else
      return false
    end
  end

  def is_over_threshold?
    if threshold 
      return coming_rsvps.count > threshold
    else
      return false
    end   
  end

  def percent_complete
    ([self.rsvps.said_yes.count.to_f/self.threshold,1].min)*100
  end    

  def rsvps_needed
    [(self.threshold - self.rsvps.said_yes.count), 0].max
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
    #Once an event expires, it cannot un-expire
    if self.status == Event::EXPIRED
      return self.status
  
    # if the deadline passed and we haven't reached the SP, finalize the event# 
    elsif deadline < DateTime.now and self.rsvps.said_yes.count < self.threshold 
      if self.status != Event::EXPIRED and send_email
        send_expiration_emails
      end
      self.status = Event::EXPIRED
    
    else 
      # otherwise, set up the status appropriately
      if self.rsvps.count == 0 # The event has been created
        self.status = Event::INITIALIZED
      elsif tipped?  # The event is on!
        send_confirmation_emails if (self.status != Event::CONFIRMED and send_email)
        self.status = Event::CONFIRMED
      else # The event is awaiting RSVPs
        self.status = Event::OPEN
      end
    end

    self.save

    return self.status 
  end

  def new_comments
    self.comment_threads.where("created_at > ?", self.comments_last_mailed || self.created_at).order('created_at')
  end

  def invitee_emails_are_valid emails
    
    if emails.blank?
      return true
    end 
    emails = emails.split(/[,\n]/)
    emails.each do |email|
      unless email.blank?
        unless valid_email(email.strip.downcase)
          errors.add(:invitee_emails, email + " is not a valid email.")
          return false
        end
      end
    end

    return true

  end

  def has_passed?
    return self.time < Time.now
  end 

  def deadline_passed?
    return self.deadline < Time.now
  end

  def expired?
    return self.status == Event::EXPIRED
  end

  ####### Custom Getters/Setters #####
  def invitee_emails
    nil
  end

  def invitee_emails=(value)

    create_owner_rsvp

    emails = value.split(/[\n,]/).map(&:strip).reject(&:blank?)
    create_rsvps emails
    
  end

  def create_rsvps emails
    emails.each do |email|
      unless email.blank?
        user = User.find_or_create_by(email: email.strip.downcase) do |u|
          u.password = u.password_confirmation = Devise.friendly_token.first(8)
        end

        #delete the unfriendship
        unfriendships = Unfriendship.where(user: self.owner, unfriend: user)
        unfriendships.destroy_all

        rsvp = Rsvp.where(user: user, event: self).first_or_create
        rsvp.emailed = false
        rsvp.new_record?
        rsvp.generate_hash_key
        rsvp.save!
      end
    end 
  end

  def create_rsvps_from_ids ids
    ids.each do |id|
      user = User.find(id)
      unless id.blank?
        user = User.find(id)
        rsvp = Rsvp.where(user: user, event: self).first_or_create
        rsvp.emailed = false
        rsvp.new_record?
        rsvp.generate_hash_key
        rsvp.save!
      end
    end
  end

  def my_people_emails
    self.owner.my_people
  end

  #from auto_html gem how-to
  auto_html_for :description do
    html_escape
    image(:width => 50)
    youtube(:width => 700, :autoplay => false)
    link :target => "_blank", :rel => "nofollow"
    simple_format
  end

  def sipping_points
    SippingPoints::Event::TIPPED[tipped?] +
    coming_rsvps.count * SippingPoints::Event::ATTENDEE
  end

  ### End Custom Getters/Setters #####

  ########## String Generators #######

  def html_description #this method can be made obsolete by switching to auto_html
    if self.description_html
      return self.description_html
    elsif self.description
      return self.description.gsub("\n", "<br>")
    else 
      return ""
    end 
  end

  def email_description
    return self.html_description.gsub("<img src", "<img style='max-width: 600px;' src")
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
    if(time.in_time_zone(timezone).year - Time.now.in_time_zone(timezone).year).abs > 0 and (time.in_time_zone(timezone) - Time.now.in_time_zone(timezone)).abs > 3*30*24*3600
      time.in_time_zone(timezone).strftime("%a, %b %-d, %Y %l:%M %p").gsub("  ", " ")
    else
     time.in_time_zone(timezone).strftime("%a, %b %-d, %l:%M %p").gsub("  ", " ")
    end
  end 

  def display_wordy time
    #If time is not this year AND the month is more than 90 days away from now
    if(time.in_time_zone(timezone).year - Time.now.in_time_zone(timezone).year).abs > 0 and (time.in_time_zone(timezone) - Time.now.in_time_zone(timezone)).abs > 3*30*24*3600
      time.in_time_zone(timezone).strftime("%A, %B %-d, %Y at %l:%M %p").gsub("  ", " ")
    else
     time.in_time_zone(timezone).strftime("%A, %B %-d at %l:%M %p").gsub("  ", " ")
    end
  end

  def yes_count_phrase
    yes_count = self.rsvps.said_yes.count
    if yes_count == 1
      return "1 person attending"
    else
      return yes_count.to_s + " people attending"
    end
  end  

  def past_yes_count_phrase
    yes_count = self.rsvps.said_yes.count
    if yes_count == 1
      return "1 person said Yes"
    else
      return yes_count.to_s + " people said Yes"
    end
  end



  def short_description
    case self.status
    when Event::OPEN
      return "Waiting for RSVPs" 
    when Event::INITIALIZED
      return "Invitations not Sent"
    when Event::EXPIRED
      return "Not Happening"
    when Event::CONFIRMED
      return "It's On!"
    end
  end

  def wordy_html_status
    case self.status
    when Event::OPEN
      return "You have been invited, but this event won't happen unless we can get at least <strong>" + self.threshold.to_s + " " + "person".pluralize(self.threshold) + "</strong> to commit before the deadline."
    when Event::INITIALIZED
      return "How did you get here?  Invitations haven't been sent yet."
    when Event::EXPIRED
      return "This event failed to reach the Sipping Point.  Don't bother showing up because no one else is going to be there."
    when Event::CONFIRMED
      return "This event is officially happening!"
    end
  end

  ####### End String Generators ###

  ########### Emails ##############

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
        rsvp.reminded = Time.now
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

  def send_report_email
    UserMailer.report_email(self).deliver!
    self.report_sent = true
    self.save 
  end 

  #Remind people who said Yes that the event is happening in 24 hours
  def send_reminder_emails
    rsvps = Rsvp.needs_reminder_of_event_email
    
    rsvps.each do |rsvp| 
      UserMailer.reminder_email(rsvp).deliver! 
      rsvp.reminder_to_attend_sent = true
      rsvp.save
    end

  end

  ########### End Emails ##############

  def update_is_tipped
    update!(is_tipped: tipped?)
  end

  private

  ### Custom Validations
  def rsvp_deadline_is_before_event
    if deadline and deadline > time
      errors.add(:deadline, "The deadline must be before the event starts")
    end
  end

  def maximum_is_not_less_than_sipping_point
    if maximum_attendance and maximum_attendance < threshold
      errors.add(:maximum_attendance, "Maximum can't be lower than the Sipping Point")
    end
  end

  def event_time_not_in_past
    if time and (Time.now + 1.minutes > time)
      errors.add(:time, "Event has to be in the future.")
    end
  end

  def rsvp_deadline_not_in_past
    if deadline and (Time.now + 1.minutes > deadline)
      errors.add(:deadline, "The deadline must be in the future.")
    end
  end

  def valid_email(email)
    return email=~/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i
  end

end
