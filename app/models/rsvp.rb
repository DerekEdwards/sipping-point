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

  # If somebody changes their response, ensure the parent event knows
  after_save :update_parent_event

  #Validations
  validates :hash_key, uniqueness: true

  #Scopes
  scope :said_yes, -> { where(response: Rsvp::YES) }
  scope :said_no, -> { where(response: Rsvp::NO) }
  scope :unanswered, -> { where(response: nil) }
  scope :upcoming, -> { joins(:event).where("time >= ?", Time.now - 2*3600) }
  scope :prior, -> { joins(:event).where("time < ?", Time.now - 2*3600) }
  scope :wants_comments_emails, -> { where(wants_comments_emails: true, viewed: true)}
  scope :reported, -> { where.not(:attendance_report => nil) }
  scope :flaked, -> {where(:attendance_report => Rsvp::FLAKED)}
  scope :showed, -> {where(:attendance_report => Rsvp::SHOWED)}
  scope :needs_reminder_of_event_email, -> { joins(:event).where("time > ? and time < ? and status = ? and response = 1 and reminder_to_attend_sent = false", Time.now, Time.now + 24*3600, Event::CONFIRMED)}
  scope :not_hidden, -> {where(:hidden => false)}
  scope :hidden, -> {where(:hidden => true)}
  scope :not_expired, -> { joins(:event).where("status <> ?", Event::EXPIRED)}
  scope :left_excuse, -> {where("excuse <> ''")}
  scope :viewed, -> {where(viewed: true)}
  scope :sorted_by_earliest, -> { joins(:event).order('events.time ASC') }
  scope :sorted_by_latest, -> { joins(:event).order('events.time DESC') }

  #Constants
  FLAKED = 0
  SHOWED = 1
  NO_RESPONSE = -1
  
  NO = 0
  YES = 1

  #Methods 
  def to_param
    self.hash_key
  end 

  def yes?
    return self.response == Rsvp::YES
  end

  def no?
    return self.response == Rsvp::NO
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

  # Users accrue points simply for responding, whether yes or no
  def sipping_points
    SippingPoints::Rsvp::RESPONDED    
  end

  # Points From this user's attendance reports
  # Note: this will be prettier if AttendanceReport can be extracted to its
  # own resource.  Also better Normal Form for the DB...
  def attendance_points
    SippingPoints::Attendance::REPORT[attendance_report]
  end

  #retuns a boolean and a message
  def editable?
    
    if self.event.deadline_passed?
      return false, "The deadline to RSVP to this event has passed."
    end

    case self.event.status
      when Event::OPEN
        return true, ""
      when Event::CONFIRMED
        if self.response == Rsvp::YES
          if self.event.is_over_threshold?
            return true, "Do you still want to come?"
          else
            return false, "You cannot change your RSVP to No unless at least 1 more person joins the event. So go find someone to take your place and come back and try again."
          end
        else 
          if self.event.has_spots_remaining?
            return true, "We hope you can join us."
          else
            return false, "<h3>Sadly this event is full. Try to be a little quicker next time.</h3>"
          end
        end
      else
        return false, "The event is not accepting RSVPs"
    end
  end

  ########## String Generators #######

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
      hours = (time_diff/(3600.0)).round
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

  def simple_status_string
    if self.event.expired?
      return 'Event Failed'
    end

    case self.response
    when Rsvp::YES
      return 'Going'
    when Rsvp::NO
      return 'Not Going'
    else
      return 'RSVP Needed'
    end
  end

  def past_simple_status_string
    if self.event.expired?
      return 'Event Failed'
    end

    case self.response
    when Rsvp::YES
      return 'Said Yes'
    when Rsvp::NO
      return 'Said No'
    else
      return 'Did not RSVP'
    end
  end

  ####### End String Generators ###

  ########### Emails ##############
  
  def send_rsvp_reminder_email
    UserMailer.rsvp_reminder_email(self).deliver!
    self.reminded = Time.now
    self.save 
  end 
  
  ########### End Emails ##########

  private

  def update_parent_event
    event.update_is_tipped
  end

end
