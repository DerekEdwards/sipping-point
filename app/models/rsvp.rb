############################################################################### 
# 
# Represents a user and event and their response
#
# Rsvp is a renaming of events_users table
# 
###############################################################################
class Rsvp < ActiveRecord::Base
  UNRESPONDED =  0
  NO          = -1
  YES         =  1

  belongs_to :user
  belongs_to :event


  def generate_hash_key
    hash_key = Digest::MD5.hexdigest(self.event.name + self.user.email + DateTime.now.to_s + rand.to_s)
    self.hash_key = hash_key
    self.save
    hash_key 
  end

end