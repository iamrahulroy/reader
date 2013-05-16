require 'spec_helper'

describe FetchFeedService do

  it "should have an attr_reader for url", :vcr => {:record => :once} do
    fetch = FetchFeedService.new(url: "http://news.ycombinator.com/rss")
    expect(fetch.url).to eq("http://news.ycombinator.com/rss")
  end

  it 'returns a body', :vcr => {:record => :once} do
    fetch = FetchFeedService.new(url: "http://news.ycombinator.com/rss")
    fetch.perform
    expect(fetch.body).to include("<rss version=\"2.0\"><channel><title>Hacker News</title>")
  end

  it 'has the correct URL when redirected', :vcr => {:record => :once} do
    pending "Can't get this to work under test env"
    fetch = FetchFeedService.new(url: "http://news.ycombinator.com/rss")
    fetch.perform
    expect(fetch.url).to eq("https://news.ycombinator.com/rss")
  end
end
