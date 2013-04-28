require 'features/spec_acceptance_helper'

describe "anonymous user visits site", :type => :feature, :vcr => {:record => :new_episodes} do
  it "default feeds are visible", :js => true do
    create_anon_feeds
    Feed.order("id ASC").first.name.should include "AmazingSuperPowers: Webcomic at the Speed of Light"
    FeedIcon.count.should eq 4
    visit "/"
    page.should have_content "Comics"
    page.should have_content "Interesting"
    click_link "Comics"
    page.source.scan("favicon").length.should eq 4
  end
end
