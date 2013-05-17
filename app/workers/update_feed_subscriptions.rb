class UpdateFeedSubscriptions
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  def perform(id)
    feed = Feed.find(id)
    feed.update_subscriptions
  end
end
