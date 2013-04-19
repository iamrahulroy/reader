class DiscoverFeedService
  attr_reader :url, :feeds

  def self.perform(url)
    @url = url
    @feeds = Feediscovery::DiscoverFeedService.new(feed_url).result
    self
  end

  def self.refine

  end

end
