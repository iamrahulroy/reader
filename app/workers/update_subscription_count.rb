class UpdateSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform(id)
    sub = Subscription.where(id: id).first
    sub.update_counts if sub
  end

end
