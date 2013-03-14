class UpdateSubscriptionCount
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform
    Subscription.update_counts
    UpdateSubscriptionCount.perform_in 1.hours
    GC.start
  end

  add_transaction_tracer :perform, :category => :task
end