class DiscoverFeedService
  attr_reader :url, :feeds

  def self.perform(url)
    @url = url
    @feeds = Feediscovery::DiscoverFeedService.new(url).result
    self
  end

  def self.discover(url)
    @url = url
    Feediscovery::DiscoverFeedService.new(url).result
  end

  def self.refine

  end

end
