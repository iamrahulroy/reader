class ExpireClient
  include Sidekiq::Worker
  sidekiq_options :queue => :clients
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)

    Client.where(:id => id).each do |client|
      client.destroy
    end
  end

  add_transaction_tracer :perform, :category => :task
end
