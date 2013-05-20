require 'features/spec_acceptance_helper'

feature "users can create groups in their feed list", :js => true do

  before :each do
    create_anon_feeds
    @user = create_user
    @user.reload.items.count.should eq 10
    sign_in_as(@user)
  end

  scenario "create a group", :vcr => {:record => :once} do
    page.should have_content "Interesting"
    find('#nav-add-link').click
    find('.add-group-link').click
    fill_in "group-label", :with => "My New Feed Group"
    click_button "Create"

    page.should have_content "My New Feed Group (0)"
  end

end
