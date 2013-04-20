require 'features/spec_acceptance_helper'

describe "anonymous user visits site", :type => :feature do
  it "default feeds are visible", :js => true, :vcr => {:record => :new_episodes} do
    create_anon_feeds
    Feed.first.name.should include "AmazingSuperPowers: Webcomic at the Speed of Light"
    FeedIcon.count.should eq 2
    visit "/"
    page.should have_content "Comics"
    page.should have_content "Interesting"
    click_link "Comics"
    page.source.scan("favicon").length.should eq 2
  end
end
