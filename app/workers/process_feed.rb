class ProcessFeed
  include Sidekiq::Worker
  sidekiq_options :queue => :process

  def perform(feed_id, file_path)
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
      ap "THIS BROKE"
      return
    end

    cutoff = DateTime.now - 1.week
    parsed_feed.entries.each do |entry|
      #if entry.published.nil? #|| cutoff < entry.published
        ProcessFeed.process_entry(feed_id, (entry.try(:content) || entry.summary), entry.summary, entry.entry_id, entry.url, entry.published.to_s, entry.updated.to_s, entry.title, entry.author)
      #end
    end

    # update the subscriptions
    feed = Feed.where(id: feed_id).first
    feed.subscriptions.each {|sub| sub.update_counts }

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



  def self.process_entries(feed_id, entries, push=false)
    entries.each do |entry|
      process_entry(feed_id, entry.content, entry.summary, entry.entry_id, entry.url, entry.published.to_s, entry.updated.to_s, entry.title, entry.author)
    end
  end

  def self.process_entry(feed_id, content, summary, entry_id, url, published, updated, title, author)
    return if url.blank?

    content = content
    content ||= summary

    guid = entry_id
    guid ||= url

    #eg = EntryGuid.find_or_initialize_by_feed_id_and_guid(feed_id, guid)
    entry_model = Entry.find_or_initialize_by_feed_id_and_guid(feed_id, guid)

    entry_date = published || updated
    entry_date = Time.current.to_formatted_s(:db) + " UTC" unless entry_date.present?
    if entry_model.new_record?
      entry_model.attributes= {:feed_id => feed_id,
                               :title => title,
                               :author => author,
                               :content => content,
                               :url => url,
                               :guid => guid,
                               :published_at => entry_date}

      entry_model.save!

    else
      entry_model.update_attributes!(:feed_id => feed_id,
                                     :title => title,
                                     :author => author,
                                     :content => content,
                                     :url => url,
                                     :guid => guid,
                                     :published_at => entry_date)
    end


  rescue ActiveRecord::RecordNotUnique => e
    ap "ActiveRecord::RecordNotUnique #{e}"
  rescue ActiveRecord::RecordInvalid => e
    ap "ActiveRecord::RecordInvalid #{e}"
  end
end