class Prune
  include Sidekiq::Worker
  sidekiq_options :queue => :background
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def perform
    items = Item.where("unread = false AND starred = false AND shared = false AND has_new_comments = false").where("created_at < ?", Date.current - 3.months)
    puts "#{items.length} items to delete"
    items.find_each do |i|
      if i.comments.empty?
        i.destroy
      end
    end

    Feed.find_each do |f|
      unless f.private
        if f.subscriptions.empty?
          puts "destroy #{f.name}"
          f.destroy
        end
      end
    end

    entries = []
    Entry.find_each do |e|
      if e.items.empty?
        entries << e
      end
    end

    puts "#{entries.length} entries to delete"
    entries.each do |e|
      e.destroy
    end
  end

  add_transaction_tracer :perform, :category => :task
end

