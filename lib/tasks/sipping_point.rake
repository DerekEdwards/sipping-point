namespace :sipping_point do
  desc "Update all open statuses that have expired"
  task update_statuses: :environment do
  	Event.open.deadline_passed.each do |event|
  	  event.update_status(send_email=true)
  	end
  end

end
