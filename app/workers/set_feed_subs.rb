class SetFeedSubs
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  def perform(id)
    feed = Feed.find(id)
    Rails.logger.debug "updating feed subs #{feed.id} - #{feed.name}"
    feed.subs = feed.subscriptions
  rescue
    Rails.logger.debug "SetFeedSubs #{id} error #{$!}"
  end
end