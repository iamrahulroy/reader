class AddEntryGuidIdToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :entry_guid_id, :integer
  end
end
