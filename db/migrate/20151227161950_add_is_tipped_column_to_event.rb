class AddIsTippedColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_tipped, :boolean, :default => false, :null => false

    # One time, we need to bump all counters to correct level
    Rake::Task['sipping_point:update_event_tipped_column'].invoke
  end
end
