class UpdateUserSubscriptionCounts
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  def perform(user_id)
    user = User.find(user_id)
    user.subscriptions.each do |sub|
      PollFeedNow.perform_async sub.feed.id
      sub.update_counts
    end
  end
end
