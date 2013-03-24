require 'features/spec_acceptance_helper'

feature "Keyboard navigation", :js => true, :vcr => true do
  scenario "keystrokes" do

    user = create_user_a
    run_jobs

    user.reload

    user.subscribe_to_url "http://feeds.feedburner.com/makezineonline", user.groups.create(:label => "diy")
    user.subscribe_to_url "http://xkcd.com/atom.xml"

    run_jobs
    sign_in_as(user)

    run_jobs

    visit "/"
    sleep 1
    click_link "diy"

    unread_item_count = user.items.filter(:unread).count
    10.times do
      sleep 0.2
      page.driver.browser.execute_script "App.nextItem()"
    end
    sleep 1
    user.items.filter(:unread).count.should == unread_item_count - 10
    page.driver.browser.execute_script "App.showList()"
    visit "/"
    sleep 1
    click_link "xkcd"
    unread_item_count = user.items.filter(:unread).count
    sleep 1
    4.times do
      sleep 0.2
      page.driver.browser.execute_script "App.nextItem()"
    end
    sleep 1
    user.items.filter(:unread).count.should == unread_item_count - 4

  end

  scenario "keystrokes in firefox"
end