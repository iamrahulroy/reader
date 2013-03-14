class UnshareItem
  include Sidekiq::Worker
  sidekiq_options :queue => :items
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)
    item = Item.find id

    item.children.each do |child|
      child.destroy
    end
    item.update_column :share_delivered, false

  end

  add_transaction_tracer :perform, :category => :task
end