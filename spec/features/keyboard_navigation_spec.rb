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
    sleep 1
    page.driver.browser.execute_script "App.showList()"
    within "#list" do
      #find("#subscription-#{user.subscriptions.first.id} .subscription-link a").click
      click_link "MAKE (10)"
    end

    unread_item_count = user.items.filter(:unread).count
    unread_item_count.should == 14
    unread_item_count.times do
      sleep 0.5
      page.driver.browser.execute_script "App.nextItem()"
    end
    sleep 1
    user.items.filter(:unread).count.should == 0

  end

end