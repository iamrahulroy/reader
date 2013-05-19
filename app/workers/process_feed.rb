require 'open-uri'

class ProcessFeed
  include Sidekiq::Worker
  sidekiq_options :queue => :process

  def perform(id)
    #body = File.open(file_path, "r").read

    feed = Feed.where(id: id).first
    body = feed.document_text
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


      #feed.increment!(:parse_errors) if feed
      em =  "ERROR: #{$!}: #{id} - #{feed.try(:feed_url)}"
      Rails.logger.debug em
      Rails.logger.debug t
      ap "THIS BROKE"
      return
    end

    feed.site_url = parsed_feed.url
    feed.description = parsed_feed.description if parsed_feed.respond_to?(:description) && parsed_feed.description
    feed.name = parsed_feed.title if parsed_feed.respond_to?(:title) && parsed_feed.title
    feed.save! if feed.changed?

    entries = parsed_feed.entries.select do |entry|
      EntryGuid.where(source_id: feed.id, source_type: 'Feed', guid: ProcessFeed.entry_guid(entry)).count == 0
    end

    entries.each do |entry|
      ProcessFeed.process_entry(id, entry)
    end

    #PollFeed.requeue_polling(id)

    unless entries.empty?
      feed.subscriptions.each { |sub| UpdateSubscriptionCount.perform_async(sub.id) }
    end

  #rescue
    #binding.pry
    #feed.increment!(:parse_errors) if feed
    #em =  "ProcessFeed Error: #{$!}: #{id} - #{feed.try(:feed_url)}"
    #ap em
  end


  def self.process_entries(feed_id, entries)
    entries.each do |entry|
      process_entry(feed_id, entry)
    end
  end

  def self.entry_guid(entry)
    guid = entry.respond_to?(:guid) ? entry.guid : nil
    guid ||= entry.respond_to?(:entry_id) ? entry.entry_id : nil
    guid ||= entry.url
    guid ||= entry.title
  end

  def self.process_entry(feed_id, entry)
    content = entry.respond_to?(:content) ? entry.content : nil
    content ||= entry.summary

    guid = entry_guid(entry)

    url = entry.url || guid
    feed = Feed.find(feed_id)
    if url && guid
      entry_model = Entry.find_or_initialize_by_source_id_and_source_type_and_guid(feed.id, feed.class.name, guid)

      entry_date = entry.published
      entry_date ||= (entry.respond_to?(:updated)) ? entry.updated : nil
      entry_date ||= Time.current.to_formatted_s(:db) + " UTC"

      if entry_model.new_record?
        entry_model.attributes= {:source_id => feed_id,
                                 :source_type => 'Feed',
                                 :title => entry.title,
                                 :author => entry.author,
                                 :content => content,
                                 :url => url,
                                 :guid => guid,
                                 :published_at => entry_date}

        entry_model.save!
        Rails.logger.info "Added entry to #{feed_id}: #{entry.title}"
      else
        entry_model.update_attributes!(:source_id => feed_id,
                                       :source_type => 'Feed',
                                       :title => entry.title.truncate(1000),
                                       :author => entry.author.truncate(1000),
                                       :content => content,
                                       :url => url,
                                       :guid => guid,
                                       :published_at => entry_date)
      end
    end
  end
end
