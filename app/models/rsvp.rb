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

  #Constants
  UNRESPONDED =  0
  NO          = -1
  YES         =  1

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