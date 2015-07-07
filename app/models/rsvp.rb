############################################################################### 
# 
# Represents a user and event and their response
#
# Rsvp is a renaming of events_users table
# 
###############################################################################
class Rsvp < ActiveRecord::Base
  
  #Relationships
  belongs_to :user
  belongs_to :event

  #Validations
  validates :hash_key, uniqueness: true

  #Scopes
  scope :said_yes, -> { where(response: 1) }
  scope :said_no, -> { where(response: 0) }
  scope :unanswered, -> { where(response: nil) }
  scope :upcoming, -> { joins(:event).where("time >= ?", Time.now - 2*3600) }
  scope :prior, -> { joins(:event).where("time < ?", Time.now - 2*3600) }
  scope :wants_comments_emails, -> { where(wants_comments_emails: true)}
  scope :reported, -> { where.not(:attendance_report => nil) }
  scope :flaked, -> {where(:attendance_report => Rsvp::FLAKED)}
  scope :showed, -> {where(:attendance_report => Rsvp::SHOWED)}

  #Constants
  FLAKED = 0
  SHOWED = 1

  #Methods 
  def to_param
    self.hash_key
  end 

  def generate_hash_key
    if self.hash_key
      return self.hash_key
    else     
      hash_key = Digest::MD5.hexdigest(self.event.name + self.user.email + DateTime.now.to_s + rand.to_s)
      self.hash_key = hash_key
      self.save
      return hash_key
    end 
  end

end