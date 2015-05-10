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

  #Constants
  INITIALIZED = 'initalized'
  OPEN = 'open'
  EXPIRED = 'expired'
  CONFIRMED = 'confirmed'

  #Scopes
  scope :open, -> { where(status:Event::OPEN) }
  scope :deadline_passed, -> { where("deadline < ?", DateTime.now) }

  #Methods
  def to_param
    self.hash_key
  end 

  def invitee_emails=(value)

    create_owner_rsvp

  	emails = value.split(',')
  	emails.each do |email|
  	  user = User.find_or_create_by(email: email.strip.downcase) do |u|
        u.password = u.password_confirmation =Devise.friendly_token.first(8)
      end

      rsvp = Rsvp.where(user: user, event: self).first_or_create
      rsvp.generate_hash_key
      rsvp.save!
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
    #The event has been created
    if self.rsvps.count == 0
      self.status = Event::INITIALIZED

    #The event is on
    elsif self.rsvps.said_yes.count >= self.threshold
      if self.status != Event::CONFIRMED and send_email
        send_confirmation_emails
      end
      self.status = Event::CONFIRMED

    #The deadline has passed
    elsif self.deadline < DateTime.now
      if self.status != Event::EXPIRED and send_email
        send_expiration_emails
      end
      self.status = Event::EXPIRED

    #The event is awaiting RSVPs
    else
      self.status = Event::OPEN
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
    self.rsvps.each do |rsvp|
      UserMailer.confirmation_email(rsvp).deliver!
    end
  end   

  def send_expiration_emails
    self.rsvps.each do |rsvp|
      UserMailer.expiration_email(rsvp).deliver!
    end
  end 

  def send_rsvp_emails
    self.rsvps.each do |rsvp| 
      UserMailer.invite_email(rsvp).deliver!
    end
  end  


  def invitee_emails
  	nil
  end

end
