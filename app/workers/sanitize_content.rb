class SanitizeContent
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  attr_accessor :entry
  def perform(id)
    @entry = Entry.find(id)

    @entry.sanitize_content
    @entry.content_sanitized = true
    @entry.save!
  end

  add_transaction_tracer :perform, :category => :task
end