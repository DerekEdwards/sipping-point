namespace :sipping_point do
  desc "Update all open statuses that have expired"
  task update_statuses: :environment do
  	Event.open.deadline_passed.each do |event|
  	  event.update_status(send_email=true)
  	end
  end

  desc "Send hourly comments emails"
  task send_new_comments_hourly: :environment do 
  	#Task is designed to run at least once per hour.  It is ok to run it more, duplicate emails will not be sent.  That logic is stored on the event model.
    new_comments = Comment.where("created_at > ? AND commentable_type = ?", Time.now - 1.hours - 5.minutes, "Event")
    events_with_new_comments = []
    new_comments.each do |comment|
    	unless comment.commentable.in? events_with_new_comments
    		events_with_new_comments << comment.commentable
    	end
    end

    events_with_new_comments.each do |event|
      event.send_comments_emails
    end
  end		

  desc "Send daily comments emails"
  task send_new_comments_daily: :environment do 
    #Task is designed to run at least once per hour.  It is ok to run it more, duplicate emails will not be sent.  That logic is stored on the event model.
    new_comments = Comment.where("created_at > ? AND commentable_type = ?", Time.now - 24.hours - 5.minutes, "Event")
    events_with_new_comments = []
    new_comments.each do |comment|
      unless comment.commentable.in? events_with_new_comments
        events_with_new_comments << comment.commentable
      end
    end

    events_with_new_comments.each do |event|
      event.send_comments_emails
    end
  end 

  desc "Send report emails"
  task send_report_emails: :environment do
    #Task should run hourly.
    Event.ready_for_report.each do |e|
      e.send_report_email
    end
  end

  desc "Send Reminders to everyone who said yes"
  task send_reminders_to_everyone_who_said_yes: :environment do
    #Task should run hourly (ok run dail on staging)
    Event.happening_within_24hrs.each do |event|
      event.send_reminder_emails
    end
  end

  desc "Update events with their number of yes's"
  task update_event_tipped_column: :environment do
    Event.all.each do |e|
      e.update_is_tipped
    end
  end

end
