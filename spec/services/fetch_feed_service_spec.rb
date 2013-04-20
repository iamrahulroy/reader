require 'spec_helper'

describe FetchFeedService do

  it "should have an attr_reader for url" do
    fetch = FetchFeedService.new("http://news.ycombinator.com/rss")
    expect(fetch.request_url).to eq("http://news.ycombinator.com/rss")
  end

  it 'returns a body' do
    VCR.use_cassette 'FetchFeedService returns a body' do
      fetch = FetchFeedService.new("http://news.ycombinator.com/rss")
      fetch.perform
      expect(fetch.body).to include("<rss version=\"2.0\"><channel><title>Hacker News</title>")
    end
  end

  it 'has the correct URL when redirected' do
    VCR.use_cassette 'FetchFeedService has the correct URL when redirected' do
      fetch = FetchFeedService.new("http://news.ycombinator.com/rss")
      fetch.perform
      expect(fetch.url).to eq("https://news.ycombinator.com/rss")
    end
  end
end
