require 'spec_helper'

describe PollFeed do

  let!(:user) { User.create! name: "Bob", email: "bob@example.com", password: '123456' }
  let!(:feed) { Feed.create! name: "Feed 1", feed_url: "http://feeds.feedburner.com/zefrank", site_url: "http://www.example.com/" }
  let!(:subscription) { Subscription.create! user: user, feed: feed }

  describe "#perform", :vcr do


    it "polls a feed url for updates" do
      PollFeed.perform_async(feed.id)
      run_jobs
      Item.count.should == 15
    end

    it "updates the feed etag" do
      feed.etag.should == nil
      PollFeed.new.perform(feed.id)
      feed.reload.etag.should == "Ay256cwFBVnRBAnf6A9vSxTt08w"
    end

  end

end
