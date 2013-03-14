class ProcessEntry
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(feed_id, content, summary, entry_id, url, published, updated, title, author)
    Feeder::EntryProcessor.process_entry(feed_id, content, summary, entry_id, url, published, updated, title, author)
  end

  add_transaction_tracer :perform, :category => :task
end
