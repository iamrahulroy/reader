class UpdateUserSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(user_id)
    user = User.find(user_id)
    user.subscriptions.each {|sub| sub.update_counts }
  end

  add_transaction_tracer :perform, :category => :task
end