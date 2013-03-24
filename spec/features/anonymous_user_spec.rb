require 'features/spec_acceptance_helper'

describe "anonymous user visits site", :type => :feature do
  it "default feeds are visible", :js => true, :vcr => true do
    create_anon_feeds
    visit "/"
    page.should have_content "Comics"
    page.should have_content "Interesting"
    click_link "Comics"
    page.source.scan("favicon").length.should >= 1
  end
end