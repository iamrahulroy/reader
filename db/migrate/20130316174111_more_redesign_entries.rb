class MoreRedesignEntries < ActiveRecord::Migration
  def change
    add_column :entries, :content_inlined, :boolean, :default => false
    add_column :entries, :content_embedded, :boolean, :default => false
    add_column :entries, :content_sanitized, :boolean, :default => false
  end
end
