# The Sipping Point

## Setup the following Rake Tasks

### Check for Expired Events 
The following rake task should be scheduled to run at least once per hour.  Ideally, it will run every minute.

  * rake sipping_point:update_statuses

### Check for new comments needs to run at least once per hour.

  * rake sipping_point:send_new_comments_hourly (IMPORTANT! Make sure that events.comments_last_mailed gets set to the current time when v0.3.0 is first updated, otherwise a lot of old comments will be sent out.)

### Send Flake Emails

  * rake sipping_point:send_report_emails (IMPORTANT!  Make sure that all old emails have event.report_sent = true, otherwise the first time this runs, we will send a ton of emails out for some very old events.)

### Send Reminder emails to people who are going

  * rake sipping_point:send_reminders_to_everyone_who_said_yes

### For 0.5.1, Update all existing rsvps to be 'viewed'

  * Rsvp.update_all(viewed: true)
 
### For 0.6.0, Update is_tipped for all existing events.

  * rake sipping_point:update_event_tipped_column
 
### For 0.7.0, Add a google api key to use google sign in.

  * ENV['google_api_client_id']
  
  * Images are downloaded and not hotlinked. Do this to update all existing images
    
    Event.all.each do |e|
      
      e.save_url_photo
      
      e.save
    
    end


