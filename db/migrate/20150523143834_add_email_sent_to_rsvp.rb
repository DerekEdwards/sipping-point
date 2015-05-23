class AddEmailSentToRsvp < ActiveRecord::Migration
  def change
    add_column :rsvps, :emailed, :boolean
  end
end
