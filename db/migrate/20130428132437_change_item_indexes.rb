class ChangeItemIndexes < ActiveRecord::Migration
  def change
    add_index :items, :unread
    add_index :items, :starred
    add_index :items, :shared
    add_index :items, :commented
    add_index :items, :has_new_comments
  end
end
