class AddImageUrlToEvent < ActiveRecord::Migration
  def change
    add_column :events, :cover_photo_url, :string
  end
end
