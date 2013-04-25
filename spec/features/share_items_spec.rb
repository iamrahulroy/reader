require 'features/spec_acceptance_helper'

feature "Users share items with each other", :js => true, :vcr => {:record => :new_episodes} do

  scenario "A shares with B, B adds comment, A sees comment, B sees reply" do
    user_a = create_user_a
    user_b = create_user_b
    user_a.follow_and_unblock(user_b)
    user_b.follow_and_unblock(user_a)
    user_a.subscribe "http://xkcd.com/atom.xml"
    run_jobs
    user_a.subscriptions.length.should == 1

    sign_in_as(user_a)

    visit('/')
    # Now make sure it has items.
    within("#list") do
      items = user_a.subscriptions.order(:id).last.items.count
      page.should have_content "(#{items})"
      click_link "xkcd"
    end

    within(".focused") do
      click_button "Share"
    end
    run_jobs
    sign_out
    sign_in_as(user_b)
    sleep 1
    within("#list") do
      page.should have_content "User A"
      click_link "User A"
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
    run_jobs

    Comment.count.should == 2

    sign_out
    run_jobs
    sign_in_as(user_b)
    find("#nav-comments-link").click
    sleep 2
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
    sleep 2
    within(".focused") do
      page.should have_content "User A"
      page.should have_content "User B"
      page.should have_content "user b comment 1"
      page.should have_content "user a comment 2"
    end
  end

  scenario "User shares then unshares item" do
    user_a = create_user_a
    user_b = create_user_b
    run_jobs
    user_a.follow_and_unblock(user_b)
    user_b.follow_and_unblock(user_a)

    sign_in_as(user_a)
    click_link "Add feeds"
    fill_in "Add a feed", :with => "http://feeds.feedburner.com/stuffchristianslikeblog"
    find('#add-feed-btn').click
    sleep 2
    run_jobs
    visit('/')
    sleep 1
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

  scenario "User emails an item" do
    pending
    user_a = create_user_a
    user_a.follow_and_unblock(user_b)
    user_a.subscribe "http://xkcd.com/atom.xml"
    run_jobs
    user_a.subscriptions.length.should == 1

    sign_in_as(user_a)

    visit('/')
    # Now make sure it has items.
    within("#list") do
      items = user_a.subscriptions.order(:id).last.items.count
      page.should have_content "(#{items})"
      click_link "xkcd"
    end

    within(".focused") do
      click_button "Email"
    end
    binding.pry
    run_jobs

  end

  scenario "User shares non feed content"

  scenario "User shares non feed content"

  scenario "User C can request to follow User A via User B"
end
