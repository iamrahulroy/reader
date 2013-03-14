require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
class PollFeed
  include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform(id, url, etag = nil, first_polling = false)
    conn = Faraday.new(:url => url) do |c|
      c.response :follow_redirects
      c.adapter Faraday.default_adapter
    end

    response = conn.get do |request|
      request.headers['If-None-Match'] = etag if etag
    end
    etag = response.headers[:etag]

    case response.status
      when 200
        if response.body && response.body.present?
          body = response.body.ensure_encoding('UTF-8', :external_encoding  => :sniff, :invalid_characters => :transcode)

          file_name = "#{Rails.root}/tmp/xmls/#{id}-#{rand(0..9999)}.xml"
          File.open(file_name, "w") do |f|
            f.write body
          end
          ProcessFeed.perform_in(5.seconds, id, file_name, first_polling)

          PollFeed.perform_in(Reader::UPDATE_FREQUENCY.minutes, id, url, etag)
        end
      when 400..599, 304
        PollFeed.perform_in(6.hours, id, url, etag)
      else
        PollFeed.perform_in(6.hours, id, url, etag)
    end

  rescue ActiveRecord::RecordNotFound => e
    # do nothing
  rescue TypeError => e
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue Faraday::Error::TimeoutError => e
    # try later
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue Errno::ETIMEDOUT => e
    # try later
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue Errno::EHOSTUNREACH => e
    # try later
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue FaradayMiddleware::RedirectLimitReached => e
    # try later
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue Faraday::Error::ConnectionFailed => e
    # try later
    PollFeed.perform_in(3.hours, id, url, etag)
  rescue OpenURI::HTTPError => e
    PollFeed.perform_in(1.days, id, url, etag)
  rescue EOFError => e
    PollFeed.perform_in(1.days, id, url, etag)
  rescue Timeout::Error => e
    PollFeed.perform_in(1.days, id, url, etag)
  ensure
    #feed.save if feed && feed.fetchable?
    GC.start
  end
  add_transaction_tracer :perform, :category => :task
end
