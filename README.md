# The Sipping Point

## Configuration

### Check for Expired Events 
The following rake task should be scheduled to run at least once per hour.  Ideally, it will run every minute.

  * rake sipping_point:update_statuses

## (New in v0.3.0) 

### Check for new comments needs to run at least once per hour.

  * rake sipping_point:send_new_comments_hourly

### Send Flake Emails

  * rake sipping_point:send_report_emails (IMPORTANT!  Make sure that all old emails have event.report_sent = true, otherwise the first time this runs, we will send a ton of emails out for some very old events.)


