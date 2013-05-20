require 'features/spec_acceptance_helper'

feature "Keyboard navigation", :js => true do
  scenario "keystrokes" do
    VCR.use_cassette "keystrokes", :record => :once do
      user = create_user_a
      run_jobs
      user.reload
      user.subscribe "http://feeds.feedburner.com/makezineonline", user.groups.create(:label => "diy")
      user.subscribe "http://xkcd.com/atom.xml"
      run_jobs
      sign_in_as(user)
      page.should have_content "MAKE"
      click_link "MAKE"

      unread_item_count = user.items.filter(:unread).count
      unread_item_count.should == 6
      unread_item_count.times do
        sleep 0.3
        page.driver.browser.execute_script "App.nextItem()"
      end

      run_jobs

      user.items.filter(:unread).count.should == 0
    end
  end

end
