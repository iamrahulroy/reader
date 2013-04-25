class AddLastFetchedAtToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :last_fetched_at, :datetime
  end
end
