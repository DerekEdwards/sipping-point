class AddReminderSentToRsvp < ActiveRecord::Migration
  def change
  	add_column :rsvps, :reminder_to_attend_sent, :boolean, :default => false
  end
end
