class FetchFeedService

  include HTTParty

  attr :request_url, :url, :etag, :status, :body
  def initialize(options={})
    @url = @request_url = options[:url]
  end

  def perform(options={})
    @url = options[:url] || url
    @body = nil

    response = get_response

    if response
      @status = response.status
      @url = response.url
      @etag = response.etag
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

  def options
    {}
  end

  def get_response
    response = self.class.get @url, options
    OpenStruct.new(status: response.code, body: response.body, url: response.request.last_uri.to_s, etag: response.headers["etag"])
  end

end