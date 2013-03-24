require 'features/spec_acceptance_helper'

feature "User imports opml", :js => true do
  scenario "User imports opml" do
    pending
    user_a = create_user_a
    run_jobs

    sign_in_as(user_a)
    sleep 1

    find("#nav-settings-link").click
    sleep 1
    find("#feeds-tab").click
    sleep 1
    attach_file("opml_file", "spec/support/fixtures/subscriptions.xml")
    sleep 1

    ImportOpml.should_receive(:perform_async)

    find('#import-btn').click
    sleep 1
    page.should have_content "Your feeds are being imported."
  end

  scenario "User exports OPML"
end