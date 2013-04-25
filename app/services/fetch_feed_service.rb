class FetchFeedService

  attr :url, :status, :body, :etag, :last_fetch_date
  def initialize(args=nil)
    if args
      @url = args[:url]
      @last_fetch_date = args[:last_fetched_at]
      @etag = args[:etag]
    end
  end

  def perform(args=nil)
    if args
      @url             ||= args[:url]
      @last_fetch_date ||= args[:last_fetched_at]
      @etag            ||= args[:etag]
    end

    @body = nil

    response = get_response
    @url = response.url
    @status = response.status
    @etag = response.etag
    @body = response.body.ensure_encoding('UTF-8', :external_encoding  => :sniff, :invalid_characters => :transcode) if response.body
    self
  end

  def self.perform(url)
    self.new.perform(url)
  end

  protected

  def get_response
    request = Typhoeus::Request.new(@url, ssl_verifypeer: false, ssl_verifyhost: 2, timeout: 60, followlocation: true, maxredirs: 5, accept_encoding: "gzip", headers: {'If-Modified_since' => last_fetch_date, 'If-None-Match' => etag})
    response = request.run
    OpenStruct.new(status: response.code, url: response.effective_url, body: response.body, etag: response.headers["etag"])
  end

end
