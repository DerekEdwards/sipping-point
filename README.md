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


