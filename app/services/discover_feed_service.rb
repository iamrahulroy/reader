class DiscoverFeedService

  attr :url, :result
  def initialize(options={})
    @url = options[:url]
  end

  def perform(options={})
    @url = options[:url] || url
    @url = "http://#{@url}" unless @url.include? "http"

    get_response
  end

  def self.perform(options)
    self.new.perform(options)
  end

  protected

  def perform_request(follow = false)
    Curl::Easy.perform(disco_url) do |curl|
      curl.headers["User-Agent"] = "1kpl.us/ruby"
      #curl.verbose = true
      curl.max_redirects = 5
      curl.timeout = 30
      curl.follow_location = true if follow
      curl.on_redirect {|easy,code|
        @url = location_from_header(easy.header_str) if easy.response_code == 301
      }
    end
  end

  def disco_url
    "http://feediscovery.appspot.com/?url=#{@url}"
  end

  def get_response
    response = perform_request
    binding.pry

  end

  def location_from_header(header)
    header =~ /.*Location:\s(.*)\r/
    $1
  end

end