class ProcessFeed
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform(feed_id, file_path, first_polling = false)
    body = File.open(file_path, "r").read
    body = body.encode('UTF-8', :invalid => :replace, :replace => '')
    body = body.encode('UTF-16', :invalid => :replace, :replace => '')
    body = body.encode('UTF-8', :invalid => :replace, :replace => '')

    body = Nokogiri::XML.parse(body).to_s
    parsed_feed = Feedzirra::Feed.parse(body) do |t|
      # apparently, this block is an error handling block
      #feed = Feed.find feed_id
      #feed.parse_errors ||= 0
      #feed.parse_errors = feed.parse_errors + 1
      #feed.fetchable = false if feed.parse_errors > 10
      #feed.save
      return
    end

    cutoff = DateTime.now - 6.hours
    parsed_feed.entries.each do |entry|
      if entry.published.nil? || cutoff < entry.published || first_polling
        ProcessEntry.new.perform(feed_id, entry.content, entry.summary, entry.entry_id, entry.url, entry.published.to_s, entry.updated.to_s, entry.title, entry.author)
      end
    end

    # check if feed is now push capable
    #unless parsed_feed.hub.nil?
    #  feed = Feed.find feed_id
    #  feed.hub = parsed_feed.hub.to_s
    #  feed.topic = parsed_feed.self.to_s
    #  feed.save
    #end

    File.delete file_path
  rescue Feedzirra::NoParserAvailable => e
    ap "No valid parser error: #{file_path}"
  rescue Errno::ENOENT => e
  rescue ArgumentError => e

  end

  add_transaction_tracer :perform, :category => :task
end
