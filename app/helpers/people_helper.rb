module PeopleHelper

  def follower_links(person)
    unless current_user.following? person
      follow_link(person) + " | " + block_link(person)
    end
  end

  def following_links(person)
    stop_following_link(person)
  end

  def follow_link(person)
    "<a href='#' class='follow-person-link' data-id='#{person.id}' data-name='#{person.name}'>Follow #{person.name}</a>"
  end

  def block_link(person)
    "<a href='#' class='block-person-link' data-id='#{person.id}' data-name='#{person.name}'>Stop sharing with #{person.name}</a>"
  end

  def stop_following_link(person)
    "<a href='#' class='unfollow-person-link' data-id='#{person.id}' data-name='#{person.name}'>Stop receiving shared items from #{person.name}</a>"
  end

end
