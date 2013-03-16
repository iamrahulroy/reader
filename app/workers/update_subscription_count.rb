class UpdateSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)
    sub = Subscription.find(id)
    sub.update_counts
  end

  add_transaction_tracer :perform, :category => :task
end