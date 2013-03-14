class UpdateIcon
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform
    UpdateIcon.perform_in 12.hours
    Feed.get_icons
  end

  add_transaction_tracer :perform, :category => :task
end