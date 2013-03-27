class Feeds < ActiveRecord::Migration
  def change
    add_column :feeds, :average_posts_per_day, :integer
    add_column :feeds, :subscription_count, :integer
  end
end
