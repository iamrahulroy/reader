require 'spec_helper'

describe PollFeed do

  let!(:user) { User.create! name: "Bob", email: "bob@example.com", password: '123456' }
  let!(:feed) { Feed.create! name: "Feed 1", feed_url: "http://feeds.feedburner.com/zefrank", site_url: "http://www.example.com/" }
  let!(:subscription) { Subscription.create! user: user, feed: feed }

  describe "#perform", :vcr => {:record => :new_episodes} do

    it "polls a feed url for updates" do
      PollFeed.perform_async(feed.id)
      run_jobs
      Item.count.should == 15
    end

    it "checks for entryguids before attempting to do inserts" do
      PollFeed.perform_async(feed.id)
      run_jobs
      Item.count.should == 15
      ProcessFeed.should_not_receive :process_entry
      PollFeed.perform_async(feed.id)
      run_jobs
    end

    it "updates the feed etag" do
      feed.etag.should == nil
      PollFeed.new.perform(feed.id)
      feed.reload.etag.should == "Ay256cwFBVnRBAnf6A9vSxTt08w"
    end

    it "polls bad feeds" do
      pending "No need to run this anymore"
      feed_urls = File.readlines("spec/failed_urls.txt").collect {|line| line}
      feed_urls.each {|fu| Feed.create!(name: fu, feed_url: fu, site_url: fu) }

      user.subscriptions.each do |sub|
        PollFeed.perform_async(sub.feed_id)
      end
      PollFeed.drain

    end

  end

end
