class ChangeItemIndexes < ActiveRecord::Migration

  def up
    remove_index :items, :name => :items_flags
    add_index :items, :unread
    add_index :items, :starred
    add_index :items, :shared
    add_index :items, :commented
    add_index :items, :has_new_comments
  end

  def down
    add_index "items", ["unread", "starred", "shared", "has_new_comments"], :name => "items_flags"
    remove_index :items, :unread
    remove_index :items, :starred
    remove_index :items, :shared
    remove_index :items, :commented
    remove_index :items, :has_new_comments
  end

end
