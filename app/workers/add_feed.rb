class AddFeed
  include Sidekiq::Worker
  sidekiq_options :queue => :feeds
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(url)
  end
  add_transaction_tracer :perform, :category => :task
end
