require 'features/spec_acceptance_helper'

describe "Re-order feeds in feed list", :type => :feature, :vcr => {:record => :once} do

  before :each do
    create_anon_feeds
    @user = create_user
    @user.reload.items.count.should == 51
    sign_in_as(@user)
  end

  it "user can drag last feed to first position", :js => true do
    page.should have_content "Interesting"
    sub = @user.subscriptions.order("weight ASC").last
    sub.name.should eq "Longform"
    grp = @user.groups.order("weight ASC").first
    last_feed = all('.subscription-link').last
    first_group = all('.group-list-drop-target').first
    last_feed.drag_to first_group
    visit '/'
    page.text.should include "Comics (26) Longform (20) chainsawsuit"
  end

end

def sub_list_for(user)
  user.subscriptions.order("weight ASC").map(&:name)
end
