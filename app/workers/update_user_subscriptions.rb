class UpdateUserSubscriptions
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  def perform(user_id)
    user = User.find(user_id)
    user.set_weights
    user.subscriptions.each do |sub|
      sub.update_counts
      #PollFeedNow.perform_async(sub.feed.id) if sub.feed
    end
  end
end
