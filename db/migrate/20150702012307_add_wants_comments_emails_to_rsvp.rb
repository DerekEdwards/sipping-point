class AddWantsCommentsEmailsToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :wants_comments_emails, :boolean, :default => true 
  end
end
