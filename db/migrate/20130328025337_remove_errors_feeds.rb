class RemoveErrorsFeeds < ActiveRecord::Migration
  def change
    rename_column :feeds, :errors, :feed_errors
  end
end
