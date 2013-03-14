class AddIndexOnFeedIcons < ActiveRecord::Migration
  def change
  	add_index :feed_icons, :feed_id
  end
end
