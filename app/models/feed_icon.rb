class FeedIcon < ActiveRecord::Base
  mount_uploader :feed_icon, FeedIconUploader
  belongs_to :feed
  after_commit :set_icon_path_on_subscriptions

  def local_path
    self.feed_icon.url
    #self.uri
  end

  def set_icon_path_on_subscriptions
    feed = self.feed
    feed.subscriptions.each do |sub|
      sub.update_column :icon_path, local_path
    end
  end

end
