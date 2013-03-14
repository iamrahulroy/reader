require 'acceptance/spec_acceptance_helper'

feature "Users share items with each other", :js => true do

  scenario "A shares with B, B adds comment, A sees comment, B sees reply" do
    VCR.use_cassette('a shares with b', :record => :new_episodes) do
      user_a = create_user_a
      user_b = create_user_b
      run_jobs
      user_a.follow_and_unblock(user_b)
      user_b.follow_and_unblock(user_a)

      sign_in_as(user_a)
      click_link "Add feeds"

      fill_in "Add a feed", :with => "http://emberjs.com/blog/"

      find('#add-feed-btn').click
      sleep 3
      find('#feed_url').value.should == ""
      page.should have_content "Feed subscription added - "
      page.should have_content "http://emberjs.com/blog/"
      user_a.subscriptions.length.should == 1
      run_jobs
      visit('/')
      find("#nav-all-link").click

      # Just make sure the sub shows up in the list.
      within("#list") do
        page.should have_content "Ember Blog"
      end

      visit('/')
      # Now make sure it has items.
      within("#list") do
        page.should have_content "(5)"
        click_link "Ember Blog"
      end

      within(".focused") do
        click_button "Share"
      end
      run_jobs

      sign_out
      sign_in_as(user_b)
      sleep 2

      within("#list") do
        page.should have_content "User A (1)"
        click_link "User A (1)"
      end

      find(".comment-form-body").set "user b comment 1"
      click_button "Add Comment"

      sign_out
      run_jobs
      sign_in_as(user_a)
      find("#nav-comments-link").click

      Comment.count.should == 1

      within(".focused") do
        page.should have_content "User B"
        page.should have_content "user b comment 1"
        find(".comment-form-body").set "user a comment 2"
        click_button "Add Comment"
      end

      Comment.count.should == 2

      sign_out
      run_jobs
      sign_in_as(user_b)
      find("#nav-comments-link").click
      sleep 5
      within(".focused") do
        page.should have_content "User A"
        page.should have_content "User B"
        page.should have_content "user b comment 1"
        page.should have_content "user a comment 2"
      end

      sign_out
      run_jobs
      sign_in_as(user_a)
      find("#nav-comments-link").click
      sleep 5
      within(".focused") do
        page.should have_content "User A"
        page.should have_content "User B"
        page.should have_content "user b comment 1"
        page.should have_content "user a comment 2"
      end
    end
  end

  scenario "User shares then unshares item" do
    VCR.use_cassette('User shares then unshares item', :record => :new_episodes) do
      user_a = create_user_a
      user_b = create_user_b
      run_jobs
      user_a.follow_and_unblock(user_b)
      user_b.follow_and_unblock(user_a)

      sign_in_as(user_a)
      click_link "Add feeds"
      fill_in "Add a feed", :with => "http://feeds.feedburner.com/stuffchristianslikeblog"
      find('#add-feed-btn').click
      sleep 3
      run_jobs
      visit('/')

      within("#list") do
        click_link "Stuff Christians Like"
      end

      within(".focused") do
        click_button "Share"
        run_jobs
        click_button "Share"
        run_jobs
      end

      sign_out
      sign_in_as(user_b)
      sleep 1

      within("#list") do
        page.should_not have_content "User A (1)"
      end

    end
  end

  scenario "User emails an item"

  scenario "User shares non feed content"

  scenario "User shares non feed content"

  scenario "User C can request to follow User A via User B"
end