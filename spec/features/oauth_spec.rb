require 'features/spec_acceptance_helper'

describe "when a user tries to register with an oauth provider that does not supply email", :type => :feature do

  let(:access_token) { rand(36**40).to_s(36) }
  let(:account)      { rand(36**99).to_s(36) }
  let(:name)         { "Henry" }
  let(:email)        { "user@example.com" }
  let(:password)     { rand(36**10).to_s(10) }

  let(:auth) {
    double('authorize_service', {
      :access_token => access_token,
      :account      => account,
      :name         => name,
      :email        => nil
    })
  }

  let!(:some_user)   { User.create!(name: "Jeff", email: "jeff@example.com", password: "123456") }

  before :each do
    profile_object = {
      :access_token => access_token,
      :account => account,
      :profile => {
        :name => name,
        :email => nil
      }
    }
    JSON.stub(:parse).and_return(profile_object)
    visit "/auth/callback?code=123"
  end

  it "they will be required to enter an email and password", :js => true, :vcr => {:record => :once} do
    within "#new-user-account-form" do
      fill_in "user_email",                  :with => email
      fill_in "user_password",              :with => password
      fill_in "user_password_confirmation", :with => password
    end
    click_button "Continue"
    sleep 1

    user = User.where(email: email).first
    user.should_not be_nil
    user.singly_access_token.should eq access_token
    user.singly_account_id.should eq account
    user.name.should eq name
    user.email.should eq email

    page.should have_css("#sign-out-link")
  end

  it "they will be required to enter a password and password confirmation", :js => true, :vcr => {:record => :once} do
    within "#new-user-account-form" do
      fill_in "user_email",                  :with => email
      fill_in "user_password",              :with => password
      fill_in "user_password_confirmation", :with => password+"xxx"
    end
    click_button "Continue"
    user = User.last
    user.should_not be_valid
    page.should have_content "Password doesn't match confirmation"
  end

  it "they will be required to enter a unique email address", :js => true, :vcr => {:record => :once} do
    within "#new-user-account-form" do
      fill_in "user_email",                  :with => some_user.email
      fill_in "user_password",              :with => password
      fill_in "user_password_confirmation", :with => password
    end
    click_button "Continue"
    user = User.last
    user.should_not be_valid
    page.should have_content "Email has already been taken"
  end
end
