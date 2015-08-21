class Unfriendship < ActiveRecord::Base
  
  #Relationships
  belongs_to :user
  belongs_to :unfriend, :class_name => "User"

end
