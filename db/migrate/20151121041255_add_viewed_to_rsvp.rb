class AddViewedToRsvp < ActiveRecord::Migration
  def change
  	add_column :rsvps, :viewed, :boolean, :default => false,  :null => false
  end
end
