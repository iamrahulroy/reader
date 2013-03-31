require 'features/spec_acceptance_helper'

feature "Pay with stripe", :js => true do
  scenario "user subscribes to a plan" do
    user_a = create_user_a
    run_jobs

    sign_in_as(user_a)
    visit "/settings"

    click_button "Pay with Card"

    binding.pry
    fill_in "Card number", with: "4242424242424242"
    fill_in "Name on card", with: user_a.name
    fill_in "Expires", with: "01/20"
    fill_in "Card code", with: "123"

    within ".stripe-app" do
      click_button "Pay"
    end

    binding.pry

  end
end
