class UpdateDownstreamItem
  include Sidekiq::Worker
  sidekiq_options :queue => :items
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  def perform(id)
    item = Item.find id

    if item.has_new_comments?
      children = item.children
      children.each do |child|
        child.has_new_comments = true
        child.commented = true
        child.save
      end
    end
  rescue ActiveRecord::RecordNotFound => e

  end

  add_transaction_tracer :perform, :category => :task
end