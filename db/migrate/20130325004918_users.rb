class Users < ActiveRecord::Migration
  def change
    add_column :users, :subscription_count, :integer
    add_column :users, :unread_count, :integer
    add_column :users, :starred_count, :integer
    add_column :users, :shared_count, :integer
    add_column :users, :all_count, :integer
  end
end
