class AddRemindedToRsvp < ActiveRecord::Migration
  def change
  	add_column :rsvps, :reminded, :datetime
  end
end
