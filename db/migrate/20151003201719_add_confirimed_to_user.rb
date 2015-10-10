class AddConfirimedToUser < ActiveRecord::Migration
  def change
  	add_column :users, :confirmed, :boolean, :null => false, :default => false 
  end
end
