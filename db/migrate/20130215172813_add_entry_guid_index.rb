class AddEntryGuidIndex < ActiveRecord::Migration
  def change
    add_index(:entry_guids, [:feed_id], :order => {:feed_id => :desc}, :name => "new_entry_guid_feed_id_index")
  end
end
