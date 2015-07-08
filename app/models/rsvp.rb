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
  scope :needs_reminder_of_event_email, -> { joins(:event).where("time > ? and time < ? and status = ? and response = 1 and reminder_to_attend_sent = false", Time.now, Time.now + 24*3600, Event::CONFIRMED)}

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

  def reminded_time_string
    if self.reminded == nil
      return ""
    end
    time_diff = Time.now - self.reminded
    if time_diff < 60
      return "sent " + time_diff.round.to_s + " seconds ago"
    elsif time_diff < 3600
      minutes = (time_diff/60.0).round
      if minutes > 1
        return "sent " + minutes.to_s + " minutes ago"
      else
        return "sent " + minutes.to_s + " minute ago"
      end
    elsif time_diff < (3600*24)
      hours = time_diff/(3600.0).round
      if hours > 1
        return "sent " + hours.to_s + " hours ago"
      else
        return "sent " + hours.to_s + " hour ago"
      end
    else 
      days = (time_diff/(3600.0*24.0)).round
      if days > 1
        return "sent " + days.to_s + " days ago"
      else
        return "sent " + days.to_s + " day ago"
      end
    end

    return ""
  end

end