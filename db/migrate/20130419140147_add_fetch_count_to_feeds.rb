class AddFetchCountToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :fetch_count, :integer, :default => 0
  end
end
