class AddIndexesToEntryGuids < ActiveRecord::Migration
  def change
    add_index :entry_guids, :feed_id
    add_index :entry_guids, :guid
  end
end
