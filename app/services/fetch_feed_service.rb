class FetchFeedService

  attr :url, :etag, :status, :body
  def initialize(options={})
    @url = options[:url]
    @etag = options[:etag]
  end

  def perform(options={})
    @url = options[:url] || url
    @etag = options[:etag] || etag
    @body = nil

    response = get_response

    if response
      @etag = response.etag
      @status = response.status
      @url = response.url
      if response.body
        @body = response.body.ensure_encoding('UTF-8', :external_encoding  => :sniff, :invalid_characters => :transcode)
      end
    end
    self
  end

  def self.perform(options)
    self.new.perform(options)
  end

  protected

  def perform_request(follow = false)
    Curl::Easy.perform(@url) do |curl|
      curl.headers["User-Agent"] = "1kpl.us/ruby"
      curl.headers["If-None-Match"] = @etag if @etag
      curl.verbose = true
      curl.max_redirects = 5
      curl.timeout = 30
      curl.follow_location = true if follow
      curl.on_redirect {|easy,code|
        @url = location_from_header(easy.header_str) if easy.response_code == 301
      }
    end
  end

  def get_response
    response = perform_request

    if response.response_code == 301
      response = perform_request(true)
    end
    response.close
    OpenStruct.new(status: response.response_code, body: response.body_str, url: @url, etag: etag_from_header(response.header_str))
  end

  def location_from_header(header)
    header =~ /.*Location:\s(.*)\r/
    $1
  end

  def etag_from_header(header)
    header =~ /.*ETag:\s(.*)\r/
    $1
  end

end