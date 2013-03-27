class Entries < ActiveRecord::Migration
  def change
    add_index "entries", ["feed_id", "guid"], :name => "entries_feed_id_guid"
  end
end
