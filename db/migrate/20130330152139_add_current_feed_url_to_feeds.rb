class AddCurrentFeedUrlToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :current_feed_url, :string, :limit => 4096
  end
end
