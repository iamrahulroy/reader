require 'spec_helper'

describe ImportOpml do

  let(:user)     { User.create! name: "Bob", email: "bob@example.com", password: '123456' }
  let(:filetext) { File.open("spec/support/fixtures/less-subscriptions.xml").read }

  describe "#perform", :vcr do
    it "doesn't explode" do
      ImportOpml.new.perform(filetext, user.id)
      Feed.fetchable.count.should == 5 # Includes the shared & starred feeds for anon and bob (4 feeds).
      Subscription.count.should == 5
    end

  end

end