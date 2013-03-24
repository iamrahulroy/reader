module AcceptanceHelpers

  def sign_in_as_user
    visit "/"
    sleep 0.5
    click_link "login-link"
    sleep 0.5
    click_link "Create new account"
    sleep 0.5
    within("#register_form") do
      fill_in "Name:", :with => "Herman"
      fill_in "E-mail:", :with => "test@1kpl.us"
      fill_in "Password:", :with => "123456"
      fill_in "Password Confirmation:", :with => "123456"
    end

    find("#register-submit-link-btn").click
    sleep 0.5
  end

  def sign_in_as(user)
    visit "/"
    sleep 1
    click_link "login-link"
    sleep 1

    within("#sign_in_form") do
      fill_in "E-mail:", :with => user.email
      fill_in "Password:", :with => "123123123"
    end

    find("#login-submit-link-btn").click
    sleep 1
    visit "/"
    user.reload
  end

  def sign_out
    find("#sign-out-link").click
    sleep 1
  end

end