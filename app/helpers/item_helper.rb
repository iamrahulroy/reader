module ItemHelper

  def item_state(item)

    if item.commented
      "commented"
    elsif item.unread
      "unread"
    elsif item.starred
      "starred"
    elsif item.shared
      "shared"
    else
      "all"
    end
  end

end