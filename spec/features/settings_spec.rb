require 'features/spec_acceptance_helper'

feature "Settings", :js => true do
  scenario "adds and removes feeds" do

    VCR.use_cassette "adds and removes feeds", :record => :once do
      user_a = create_user_a
      run_jobs
      sign_in_as(user_a)
      click_link "Add feeds"
      fill_in "Add a feed", :with => "http://xkcd.com/atom.xml"
      find('#add-feed-btn').click
      page.should have_content "xkcd.com"
      fill_in "Add a feed", :with => "http://feeds.feedburner.com/amazingsuperpowers"
      find('#add-feed-btn').click
      page.should have_content "AmazingSuperPowers"
      fill_in "Add a feed", :with => "http://feeds.feedburner.com/Chainsawsuit"
      find('#add-feed-btn').click
      page.should have_content "chainsawsuit by kris straub"
      fill_in "Add a feed", :with => "reddit"
      find('#add-feed-btn').click
      page.should have_content "reddit: the front page"

      all('a.unsubscribe-link').each do |link|
        link.click
        sleep 1
      end

      visit "/settings/feeds"

      page.should_not have_content "xkcd"
      Subscription.count.should == 0
    end

  end
end
