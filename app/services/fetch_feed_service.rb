class FetchFeedService

  attr :url, :etag, :status, :body
  def initialize(options={})
    @url = options[:url]
    @etag = options[:etag]
  end

  def perform(options={})
    @url = options[:url] || url
    @etag = options[:etag] || etag

    ap "get #{@url}"
    response = get_response
    ap "got #{@url}"
    @etag = response.headers[:etag]
    @status = response.status

    if response.body && response.body.present?
      @body = response.body.ensure_encoding('UTF-8', :external_encoding  => :sniff, :invalid_characters => :transcode)
    end

    self
  end

  def self.perform(options)
    self.new.perform(options)
  end

  protected

  def get_response
    get_request.get do |r|
      r.headers['If-None-Match'] = @etag if @etag
    end
  end

  def get_request
    Faraday.new(:url => @url) do |c|
      c.response :follow_redirects
      c.adapter Faraday.default_adapter
    end
  end

end