class AddMaximumToEvent < ActiveRecord::Migration
  def change
    add_column :events, :maximum_attendance, :integer, after: :threshold
  end
end
