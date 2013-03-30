class AddConnectionErrorsToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :connection_errors, :integer, :default => 0
  end
end
