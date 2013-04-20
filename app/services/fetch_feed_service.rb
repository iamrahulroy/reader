class FetchFeedService

  attr :url, :status, :body
  def initialize(url)
    @url = url
  end

  def perform(url)
    @url = url
    @body = nil

    response = get_response

    if response
      @status = response.status
      if response.body
        @body = response.body.ensure_encoding('UTF-8', :external_encoding  => :sniff, :invalid_characters => :transcode)
      end
    end
    self
  end

  def self.perform(url)
    self.new.perform(url)
  end

  protected

  def get_response
    request = Typhoeus::Request.new(@url, followlocation: true)
    response = request.run
    OpenStruct.new(status: response.code, body: response.body, etag: response.headers["etag"])
  end

end
