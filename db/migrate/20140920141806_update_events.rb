class UpdateEvents < ActiveRecord::Migration
  def change
    add_column :events, :location, :text
    add_column :events, :time, :datetime
    add_column :events, :description, :text
    add_column :events, :owner_id, :integer, :references => :user
    add_column :events, :threshold, :integer
    add_column :events, :deadline, :datetime
  end
end
