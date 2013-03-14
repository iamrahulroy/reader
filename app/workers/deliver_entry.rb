class DeliverEntry
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)
    entry = Entry.find(id)
    entry.deliver
  ensure
    #ActiveRecord::Base.connection.flush
  end

  add_transaction_tracer :perform, :category => :task
end