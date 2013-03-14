class UnsubscribeClient
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(client_id)
    puts "unsubscribe client - #{client_id}"
    client = Client.find_by_client_id client_id
    client.destroy unless client.nil?
  end

  add_transaction_tracer :perform, :category => :task
end