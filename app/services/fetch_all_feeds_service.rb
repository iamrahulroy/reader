
module Typhoeus
  class Request
    attr_accessor :feed
  end
end

class FetchAllFeedsService

  attr_accessor :hydra
  def initialize
  end

  def perform
    @hydra = Typhoeus::Hydra.hydra
    Feed.fetchable.find_each do |feed|
      url = feed.current_feed_url || feed.feed_url
      puts url
      hydra.queue request_for(feed)
    end

    hydra.run
    #binding.pry
  end

  def request_for(feed, follow = false)
    url = feed.feed_url # feed.current_feed_url || feed.feed_url
    request = Typhoeus::Request.new(url, :method => :get, :ssl_verifyhost => 2, :timeout => 1000, :followlocation => follow)
    request.feed = feed
    request.on_complete do |response|
      handle_response response
    end
    request
  end

  def handle_response(response)
    feed = response.request.feed
    puts "#{response.response_code} - #{feed.feed_url} - #{feed.name} - #{response.total_time}" if Rails.env.development?
    case response.response_code
    when 200
      feed.increment! :fetch_count
      file = FilelessIO.new(response.body)
      file.original_filename = "feed.xml"
      feed.document = file
      feed.save!
      ProcessFeed.perform_async(feed.id)
    when 301
      feed.update_attribute :current_feed_url, response.headers["Location"]
      hydra.queue request_for(feed, true)
      #binding.pry
    when 302
      hydra.queue request_for(feed, true)
      #binding.pry
    else
      puts "timeout: #{response.timed_out?}"
      feed.increment! :connection_errors
      #binding.pry
    end
  end
end
