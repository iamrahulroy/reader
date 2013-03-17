class UpdateSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform(id)
    sub = Subscription.find(id)
    sub.update_counts
  end

end