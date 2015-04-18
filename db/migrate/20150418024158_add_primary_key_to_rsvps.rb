class AddPrimaryKeyToRsvps < ActiveRecord::Migration
  def change
  	add_column :rsvps, :id, :primary_key
  end
end
