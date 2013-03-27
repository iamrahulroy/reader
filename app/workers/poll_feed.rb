require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
class PollFeed
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform(id)

    feed = Feed.find id
    response = FetchFeedService.perform(:url => feed.feed_url, :etag => feed.etag)

    feed.update_column(:etag, response.etag)

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
        PollFeed.perform_in(6.hours, feed.id)
      else
        PollFeed.perform_in(6.hours, feed.id)
    end


  rescue NoMethodError, ArgumentError => e
  rescue TypeError => e
  rescue Encoding::CompatibilityError, Zlib::DataError, Errno::EHOSTUNREACH, Errno::ETIMEDOUT => e
  rescue URI::InvalidURIError, SocketError, FaradayMiddleware::RedirectLimitReached, Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed => e
  rescue ActiveRecord::RecordNotFound => e
    # do nothing
  end
end
