module AcceptanceHelpers

  def sign_in_as(user)
    if defined? login_as
      login_as(user, :scope => :user)
      visit "/"
    else
      visit "/"
      click_link "login-link"

      within("#sign_in_form") do
        fill_in "E-mail:", :with => user.email
        fill_in "Password:", :with => "123123123"
      end

      find("#login-submit-link-btn").click
      user.reload
      visit "/"
    end
  end


  def sign_out
    find("#sign-out-link").click
    sleep 1
  end

end