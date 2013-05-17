class AddSiteUrlAndFeedIconPathToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :site_url, :string, :limit => 4096
    add_column :subscriptions, :icon_path, :string, :limit => 4096
  end
end
