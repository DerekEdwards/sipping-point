class Event < ActiveRecord::Base

  belongs_to :owner, :class_name => "User"
  has_many   :rsvps
  has_many   :invitees, through: :rsvps, :source => "User"

  attr_accessor :owner_email
  attr_accessor :invitee_emails

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

  def invitee_emails
  	nil
  end

end
