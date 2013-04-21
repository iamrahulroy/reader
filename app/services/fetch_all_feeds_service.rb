
module Typhoeus
  class Request
    attr_accessor :feed
  end
end

class FetchAllFeedsService

  attr_accessor :hydra

  def initialize
  end

  def self.perform
    #loop do
      self.new.perform
    #end
  end

  def perform
    #Typhoeus::Config.verbose = true
    @hydra = Typhoeus::Hydra.new(max_concurrency: 200)
    Feed.fetchable.order("fetch_count ASC").limit(1000).each do |feed|
      Rails.logger.debug "Fetching #{feed.feed_url} - #{feed.name}"
      hydra.queue request_for(feed)
      hydra.run
      puts "Hydra Loop"
    end
  end

  def request_for(feed)
    url = feed.current_feed_url || feed.feed_url
    request = Typhoeus::Request.new(url, ssl_verifypeer: false, ssl_verifyhost: 2, timeout: 60, followlocation: true)
    request.feed = feed
    request.on_complete do |response|
      handle_response response
    end
    request
  end

  def handle_response(response)
    feed = response.request.feed
    puts "#{Time.current}: #{response.code} - #{feed.id} - #{feed.name} - #{response.effective_url}"
    case response.response_code
    when 200
      feed.save_document response.body
      feed.increment! :fetch_count
      feed.update_attribute(:current_feed_url, response.effective_url)
      feed.update_attribute(:etag, response.headers["etag"])
      ProcessFeed.perform_async(feed.id)
    else
      Rails.logger.debug "Fetch failed: #{feed.feed_url} - #{feed.name}"
      feed.increment! :connection_errors
    end
  end
end
