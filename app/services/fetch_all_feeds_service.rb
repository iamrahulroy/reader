
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
    loop do
      self.new.perform
    end
  end

  def perform
    @hydra = Typhoeus::Hydra.hydra
    Feed.fetchable.find_each do |feed|
      Rails.logger.debug "Fetching #{feed.feed_url} - #{feed.name}"
      hydra.queue request_for(feed)
    end

    hydra.run
  end

  def request_for(feed, follow = false)
    url = feed.current_feed_url || feed.feed_url
    request = Typhoeus::Request.new(url, ssl_verifyhost: 2, timeout: 60, followlocation: follow)
    request.feed = feed
    request.on_complete do |response|
      handle_response response
    end
    request
  end

  def handle_response(response)
    feed = response.request.feed
    case response.response_code
    when 200

      feed.save_document response.body
      feed.increment! :fetch_count
      ProcessFeed.perform_async(feed.id)
    when 301
      feed.update_attribute :current_feed_url, response.headers["Location"]
      hydra.queue request_for(feed, true)
    when 302
      hydra.queue request_for(feed, true)
    else
      Rails.logger.debug "Fetch failed: #{feed.feed_url} - #{feed.name}"
      feed.increment! :connection_errors
    end
  end
end
