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

end