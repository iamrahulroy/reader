require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
class PollFeed
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform(id)

    feed = Feed.find id
    url = feed.current_feed_url || feed.feed_url
    response = FetchFeedService.perform(:url => url, :etag => feed.etag)

    feed.update_column(:current_feed_url, response.url)
    feed.update_column(:etag, response.etag)
    feed.touch(:fetched_at)

    case response.status
      when 200
        if response.body && response.body.present?
          file_name = "#{Rails.root}/tmp/xmls/#{id}-#{rand(0..9999)}.xml"
          File.open(file_name, "w") do |f|
            f.write response.body
          end
          ProcessFeed.perform_async(id, file_name)

        end
      when 400..599, 304
        #PollFeed.perform_in(6.hours, feed.id)
      else
        #PollFeed.perform_in(6.hours, feed.id)
    end

  #rescue Faraday::Error::ConnectionFailed => e
  #  feed = Feed.where(id: id).first
  #  feed.increment!(:connection_errors) if feed
  #  em =  "ERROR: #{$!}: #{id} - #{feed.try(:feed_url)}"
  #  ap em
  rescue Curl::Err::CurlError => e
    feed = Feed.where(id: id).first
    feed.increment!(:feed_errors) if feed
    em =  "ERROR: #{$!}: #{id} - #{feed.try(:feed_url)}"
    ap em
  end
end
