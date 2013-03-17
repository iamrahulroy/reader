class UpdateUserSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  def perform(user_id)
    user = User.find(user_id)
    user.subscriptions.each {|sub| sub.update_counts }
  end
end