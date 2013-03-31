module ApplicationHelper
  def check_reader_user
    unless real_user
      sign_in(:user, User.anonymous)
    end
  end

  def real_user
    current_user && !current_user.anonymous?
  end

  def anonymous_user
    current_user.try(:anonymous?)
  end
end
