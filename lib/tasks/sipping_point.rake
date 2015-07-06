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

end
