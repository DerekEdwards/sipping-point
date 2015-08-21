class CreateUnfriendships < ActiveRecord::Migration
  def change
    create_table :unfriendships do |t|
      t.integer :user_id
      t.integer :unfriend_id
      t.timestamps
    end
  end
end