class AddCommentTimeToEvent < ActiveRecord::Migration
  def change
    add_column :events, :comments_last_mailed, :datetime
  end
end
