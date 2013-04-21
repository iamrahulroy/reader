require 'spec_helper'
describe Feed do
  describe "#merge" do

    before :each do

    end

    let(:group_a)          { Group.create! user: user_a, label: "Group 1" }
    let(:group_b)          { Group.create! user: user_b, label: "Group 1" }

    let(:user_a)                 { User.create! name: "Jack", email: "jack@example.com", password: '123456' }
    let(:user_b)                 { User.create! name: "John", email: "john@example.com", password: '123456' }

    let(:subscription_a)         { Subscription.create! user: user_a, feed: feed_a, name: "User Subscription", group: group_a }
    let(:subscription_b)           { Subscription.create! user: user_b, feed: feed_b, name: "User Subscription", group: group_b }

    #let!(:item_a)                { Item.create! user: user_a, entry: entry_a, subscription: subscription_a }
    #let!(:item_b)                { Item.create! user: user_b, entry: entry_b, subscription: subscription_b }

    let!(:icon_a)                { FeedIcon.create! feed_id: feed_a.id }
    let!(:icon_b)                { FeedIcon.create! feed_id: feed_b.id }

    let(:entry_a)  { Entry.create! guid: "123", url: "http://www.example.com/", feed: feed_a, published_at: Date.current }
    let(:entry_b)  { Entry.create! guid: "123", url: "http://www.example.com/", feed: feed_b, published_at: Date.current }

    let(:feed_a) { Feed.create! name: "Feed 1", feed_url: "http://www.example.com/foo.rss", site_url: "http://www.example.com/" }
    let(:feed_b) { Feed.create! name: "Feed 2", feed_url: "http://www.example.com/bar.rss", site_url: "http://www.example.com/" }

    # item and entry unique to feed a
    #let!(:item_c)                { Item.create! user: user_a, entry: entry_c, subscription: subscription_a }
    let(:entry_c)  { Entry.create! guid: "124", url: "http://www.example.com/", feed: feed_a, published_at: Date.current }

    before :each do
      entry_a.deliver
      entry_b.deliver
      entry_c.deliver
      feed_b.feed_url = feed_a.feed_url
      feed_b.save
    end

    it "re-parents a feeds entries" do
      Entry.where(feed_id: feed_b.id).count.should eq 0
    end

    it "re-parents a feeds subscriptions" do
      Subscription.where(feed_id: feed_b.id).count.should eq 0
    end

    it "cleans up the old entry_guids" do
      EntryGuid.where(feed_id: feed_b.id).count.should eq 0
    end

    it "deletes any feed icons" do
      FeedIcon.where(feed_id: feed_b.id).count.should eq 0
    end

    it "deletes duplicate entries" do
      Entry.where(feed_id: feed_b.id).count.should eq 0
      Entry.where(feed_id: feed_a.id).count.should eq 2
    end

    it "related items" do
      Item.where(subscription_id: subscription_a.id).count.should eq 0
      Item.where(subscription_id: subscription_b.id).count.should eq 0
    end

    it "destroys itself after merging" do
      Feed.where(id: feed_b.id).count.should eq 0
    end
  end
end
