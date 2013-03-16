class DeliverEntry
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)
    entry = Entry.find(id)
    entry.deliver
    entry.processed = true
    entry.delivered = true
    entry.save!
  rescue ActiveRecord::RecordNotFound => e
    # sometimes jobs get queued for records that don't exist. WHY?
  end

  add_transaction_tracer :perform, :category => :task
end