class AddTimezoneToEvent < ActiveRecord::Migration
  def change
    add_column :events, :timezone, :string, :default => 'America/New_York'
  end
end
