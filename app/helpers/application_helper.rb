module ApplicationHelper
  def real_user
    current_user && !current_user.anonymous?
  end

  def anonymous_user
    current_user.try(:anonymous?)
  end
end
