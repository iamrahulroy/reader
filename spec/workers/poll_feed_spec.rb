require 'spec_helper'

describe PollFeed do

  let!(:user) { User.create! name: "Bob", email: "bob@example.com", password: '123456' }
  let!(:feed) { Feed.create! name: "Feed 1", feed_url: "http://feeds.feedburner.com/zefrank", site_url: "http://www.example.com/" }
  let!(:subscription) { Subscription.create! user: user, source_id: feed.id, source_type: 'Feed' }

  describe "#perform" do

    it "polls a feed url for updates", :vcr => {:record => :once} do
      PollFeed.perform_async(feed.id)
      run_jobs
      Item.count.should == 3
    end

    it "checks for entryguids before attempting to do inserts", :vcr => {:record => :once} do
      PollFeed.perform_async(feed.id)
      run_jobs
      Item.count.should == 3
      EntryGuid.count.should ==3
      ProcessFeed.should_not_receive :process_entry
      PollFeed.perform_async(feed.id)
      run_jobs
    end

    it "updates the feed etag", :vcr => {:record => :once} do
      feed.etag.should == nil
      PollFeed.new.perform(feed.id)
      feed.reload.etag.should == "Ay256cwFBVnRBAnf6A9vSxTt08w"
    end

  end

end
