class AddHiddenToRsvp < ActiveRecord::Migration
  def change
  	add_column :rsvps, :hidden, :boolean, :default => false 
  end
end
