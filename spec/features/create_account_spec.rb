require 'features/spec_acceptance_helper'

describe "User wants to create account", :type => :feature do

  it "User creates account", :js => true, :vcr => {:record => :once} do
    visit "/"
    click_link "login-link"
    click_link "Create new account"

    within("#register_form") do
      fill_in "Name:", :with => "Herman"
      fill_in "E-mail:", :with => "test@1kpl.us"
      fill_in "Password:", :with => "123456"
      fill_in "Password Confirmation:", :with => "12345"
      find("#register-submit-link-btn").click
      fill_in "Password Confirmation:", :with => "123456"
      find("#register-submit-link-btn").click
      page.should have_content "You must agree"
      check "I agree"
      find("#register-submit-link-btn").click
    end
    sleep 1

    emails.length.should == 1
  end

  it "User forgot password", :js => true, :vcr => {:record => :once} do
    u = User.steve
    visit "/"
    click_link "login-link"
    click_link "Forgot your password?"
    within("#password_form") do
      fill_in "E-mail:", :with => "test@1kpl.us"
    end
    find("#password-submit-link-btn").click
    page.should have_content "Email not found"
    within("#password_form") do
      fill_in "E-mail:", :with => "steve@example.com"
    end
    find("#password-submit-link-btn").click
    sleep 1
    emails.length.should == 1
    last_email.body.should include "steve@example.com"
    last_email.body.should include "Change my password"
  end

  it "User closes registration modal", :js => true, :vcr => {:record => :once} do
    visit "/"
    click_link "login-link"
    click_link "Create new account"
    find("#register-modal").should be_visible
    click_link "Close"
    sleep 1
    page.text.should_not include 'Password Confirmation'
  end

end
