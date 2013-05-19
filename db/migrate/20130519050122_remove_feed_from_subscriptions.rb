class RemoveFeedFromSubscriptions < ActiveRecord::Migration
  def up
    remove_column :subscriptions, :feed_id
  end

  def down
    add_column :subscriptions, :feed_id, :integer
  end
end
