require 'features/spec_acceptance_helper'

feature "users can add feeds", :js => true do

  before :each do
    create_anon_feeds
    @user = create_user
    @user.reload.items.count.should eq 10
    sign_in_as(@user)
  end

  scenario "from the left icon bar", :vcr => {:record => :new_episodes} do
    page.should have_content "Interesting"
    find('#nav-add-link').click
    find('.add-subscription-link').click
    fill_in "feed-url", :with => "http://www.getkempt.com/feed"
    click_button "Add Feed"
    page.should_not have_content "Add new RSS feed"
    run_jobs
    send_last_sub
    page.should have_content "Kempt (3)"
  end

  scenario "from the bookmarklet", :vcr => {:record => :new_episodes} do
    visit "/api/feed/subscribe?url=#{CGI.escape('http://www.getkempt.com/feed')}"
    run_jobs
    send_last_sub
    page.should have_content "Kempt (3)"
  end

  def send_last_sub
    sub = @user.subscriptions.order("id DESC").first
    # Since we don't have private pub running in test, we;ll just pretend
    page.driver.browser.execute_script "App.receiver.addSubscription(#{sub.to_json})"
  end

end
