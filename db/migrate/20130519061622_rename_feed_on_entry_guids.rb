class RenameFeedOnEntryGuids < ActiveRecord::Migration
  def change
    rename_column :entry_guids, :feed_id, :source_id
    add_column :entry_guids, :source_type, :string, :default => 'Feed'
  end
end
