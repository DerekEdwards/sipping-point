############################################################################### 
# 
# Represents a user and event and their response
#
# Rsvp is a renaming of events_users table
# 
###############################################################################
class Rsvp < ActiveRecord::Base

  after_initialize :generate_hash_key
  
  #Relationships
  belongs_to :user
  belongs_to :event

  #Validations
  validates :hash_key, uniqueness: true

  #Scopes
  scope :said_yes, -> { where(response: 1) }
  scope :said_no, -> { where(response: 0) }
  scope :unanswered, -> { where(response: nil) }
  scope :upcoming, -> { joins(:event).where("time >= ?", Time.now - 2.hours) }
  scope :prior, -> { joins(:event).where("time < ?", Time.now - 2.hours) }

  #Methods 
  def to_param
    self.hash_key
  end 

  private

  # This is just an intrinsic detail of creating an RSVP, not something that should be exposed
  def generate_hash_key
    hash_key ||= Digest::MD5.hexdigest(self.event.name + self.user.email + DateTime.now.to_s + rand.to_s)
  end
end