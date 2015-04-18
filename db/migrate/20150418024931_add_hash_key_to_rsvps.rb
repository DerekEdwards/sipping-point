class AddHashKeyToRsvps < ActiveRecord::Migration
  def change
  	add_column :rsvps, :hash_key, :string
  end
end
