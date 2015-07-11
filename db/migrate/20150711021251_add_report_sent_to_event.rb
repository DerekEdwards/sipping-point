class AddReportSentToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :report_sent, :boolean, :default => false
  end
end
