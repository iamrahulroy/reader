class FetchFeedService

  attr :url, :status, :body, :etag
  def initialize(url=nil)
    @url = url
  end

  def perform(url=nil)
    @url ||= url
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
    request = Typhoeus::Request.new(@url, followlocation: true)
    response = request.run
    OpenStruct.new(status: response.code, url: response.effective_url, body: response.body, etag: response.headers["etag"])
  end

end
