class AddSourceToEntries < ActiveRecord::Migration
  def change
    rename_column :entries, :feed_id, :source_id
    add_column :entries, :source_type, :string, :default => 'Feed'
  end
end
