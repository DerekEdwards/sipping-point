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

  #Methods
  def to_param
    self.hash_key
  end 

  def invitee_emails=(value)
  	emails = value.split(',')
  	invitees = []
  	emails.each do |email|
  	  user = User.where(email: email.strip).first_or_create(password: 'sippingpoint', password_confirmation: 'sippingpoint')
      user.save
  	  rsvp  = Rsvp.where(user: user, event: self).first_or_create
      rsvp.generate_hash_key
      rsvp.save
      UserMailer.invite_email(rsvp).deliver! 	  

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

  def invitee_emails
  	nil
  end

end
