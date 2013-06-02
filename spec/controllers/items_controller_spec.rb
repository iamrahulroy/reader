require 'spec_helper'

describe ItemsController do
  let(:user) { create(:user) }

  before(:each) do
    sign_in(user)
  end

  describe "#email" do
    it "sends an item to a user" do
      feed = create(:feed, :user => user)
      entry = create(:entry, :feed => feed)
      item = create(:item, :user => user, :entry => entry) 
      email = {:item => item,:user => user,:to => "foo@example.com", :subject => entry.title, :body => "Lorem Ipsum..."}
      ItemMailer.item(email).deliver

      #ActionMailer.deliveries.last.should eq()
    end
  end

end
