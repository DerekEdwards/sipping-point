class AttendanceReport < ActiveRecord::Migration
  def change
  	add_column :rsvps, :attendance_report, :integer
  end
end
