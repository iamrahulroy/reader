class DeliverItemsToUser
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform(feed_id, user_id)
    feed = Feed.find feed_id
    user = User.find user_id
    feed.entries.last(15).each do |entry|
      Rails.logger.info "deliver #{entry.guid} to #{user.name}"
      entry.deliver_to user
    end
  end
end
