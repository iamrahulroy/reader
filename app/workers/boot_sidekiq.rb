class BootSidekiq
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform
    return if Rails.env.development?
    ap "KILLING PARENT PROC"
    ap `kill $PPID`
    ap "KILLED PARENT PROC"
    self.class.perform_in(5.minutes)

  end

  add_transaction_tracer :perform, :category => :task
end