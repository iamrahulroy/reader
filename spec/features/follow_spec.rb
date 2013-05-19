require 'features/spec_acceptance_helper'

feature "User A can follow User B", :js => true do

  scenario "A requests to follow B", :vcr => {:record => :once} do
    create_anon_feeds
    user_a = create_user_a
    user_b = create_user_b
    sign_in_as(user_a)
    visit "/settings"
    click_link "Friends"
    within("#invite_form") do
      fill_in "E-mail", with: user_b.email
    end
    click_button "Send invite"
    page.should have_content "Request sent"
    run_jobs
    logout(:user)
    sign_in_as(user_b)
    visit '/'
    page.should have_content "User A would like to follow your shared items"
    click_button "Accept & Follow User A"
    page.should_not have_content "User A would like to follow your shared items"
    Follow.count.should == 2
    Follow.all.each do |f|
      f.blocked.should == false
    end
  end

  scenario "A requests to follow C, who is not registered" do
    user_a = create_user_a
    run_jobs
    sign_in_as(user_a)
    visit "/settings"
    page.should have_content "Friends"
    click_link "Friends"
    within "#invite_form" do
      fill_in "E-mail", with: "c@example.com"
    end
    click_button "Send invite"
    sleep 0.5
    page.should have_content "Invite sent"
    run_jobs
    last_email.body.should include "Come check out 1kpl.us!"
  end
end
