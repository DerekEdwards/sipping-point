class AddhashKeyToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :hash_key, :string
  end
end
