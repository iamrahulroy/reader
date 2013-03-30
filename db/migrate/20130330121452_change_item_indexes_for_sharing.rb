class ChangeItemIndexesForSharing < ActiveRecord::Migration
  def up
    remove_index :items, :name => :item_user_entry
    add_index "items", ["user_id", "entry_id", "from_id"], :name => "item_user_from_entry", :unique => true
  end

  def down
    remove_index :items, :name => :item_user_from_entry
    add_index "items", ["user_id", "entry_id"], :name => "item_user_entry", :unique => true
  end
end
