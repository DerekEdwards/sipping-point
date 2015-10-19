class AddOpenToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :open, :boolean, :default => false, :null => false
  end
end
