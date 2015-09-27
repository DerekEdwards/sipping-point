class AddExcuseToRsvps < ActiveRecord::Migration
  def change
  	add_column :rsvps, :excuse, :text
  end
end
