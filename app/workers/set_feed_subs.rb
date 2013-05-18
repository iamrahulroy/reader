class SetFeedSubs
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  def perform(id)
    feed = Feed.find(id)
    Rails.logger.debug "updating feed subs #{feed.id} - #{feed.name}"
    feed.subscriptions.each do |sub|
      sub.source_id = feed.id
      sub.source_type = 'Feed'
      sub.save!
    end
  rescue
    Rails.logger.debug "SetFeedSubs #{id} error #{$!}"
  end
end