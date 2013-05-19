require 'features/spec_acceptance_helper'

describe "Re-order feeds in feed list", :type => :feature, :vcr => {:record => :once} do

  before :each do
    create_anon_feeds
    @user = create_user
    run_jobs
    @user.reload.items.count.should == 175
    sign_in_as(@user)
  end

  it "user can drag first feed to last position", :js => true do
    pending "Can't seem to get drags to test right. Works interactively."
    page.should have_content "Interesting"
    last_feed = all('.subscription-link').last
    first_group = all('.group-list-drop-target').first
    list_before = sub_list_for @user
    last_feed.drag_to first_group
    sleep 2
    list_after  = sub_list_for @user.reload
    ap list_before
    ap list_after
    list_before.first.should_not eq list_after.first
  end

end

def sub_list_for(user)
  user.subscriptions.order("weight ASC").map(&:name)
end
