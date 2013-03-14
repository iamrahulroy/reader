require 'spec_helper'

describe DeliverSubscription do

  let(:user) { User.create! name: "Bob", email: "bob@example.com", password: '123456' }
  let(:item) { Item.where(entry_id: entry.id).first }
  let!(:client) { Client.create! user: user, client_id: "1", channel: "11" }
  let(:entry) { Entry.create! guid: "123", url: "http://www.example.com/", feed: feed, published_at: Date.current }
  let(:feed) { Feed.create! name: "Feed 1", feed_url: "http://www.example.com/foo.rss", site_url: "http://www.example.com/" }
  let!(:subscription) { Subscription.create! user: user, feed: feed }

  describe "#perform" do
    it "doesn't throw an error" do
      Item.where(entry_id: entry.id).count.should == 1
      DeliverSubscription.new.perform(item.id, user.id)
    end

  end

end
