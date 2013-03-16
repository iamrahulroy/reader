class EmbedContent
  include Sidekiq::Worker
  sidekiq_options :queue => :entry
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  attr_accessor :entry
  def perform(id)
    @entry = Entry.find(id)

    if Rails.env.production?
      if @entry.feed.feed_url =~ /reddit\.com/ || @entry.feed.feed_url =~ /news\.ycombinator\.com\/rss/
        unless url =~ /reddit\.com/ || url =~ /imgur\.com/ || url =~ /qkme\.me/
          @entry.content = "#{embed_urls(url.dup, false)}<p/>#{@entry.content}"
        end
      end
    end
    @entry.content_embedded = true
    @entry.save!
  end

  add_transaction_tracer :perform, :category => :task
end