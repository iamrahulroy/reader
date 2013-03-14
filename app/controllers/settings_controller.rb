class SettingsController < ApplicationController
  def options
    singly_profile = Singly.singly_profile_for current_user

    ap singly_profile

    if singly_profile && singly_profile["services"]
      @twitter = singly_profile["services"]["twitter"]
      @facebook = singly_profile["services"]["facebook"]
      @twitter[:authorized] = true
      @facebook[:authorized] = true
    else
      @twitter = {}
      @facebook = {}
      @twitter[:authorized] = false
      @facebook[:authorized] = false
    end
    @twitter[:service_name] = "Twitter"
    @facebook[:service_name] = "Facebook"

    @twitter[:sharing_to] = current_user.share_to_twitter
    @facebook[:sharing_to] = current_user.share_to_facebook
    render :layout => nil, :template => 'settings/options'
  end

  def your_feeds
    @subscriptions = Subscription.where(:user_id => current_user.id)
    render :layout => nil, :template => 'settings/subscription_table'
  end

  def suggested_feeds
    @feeds = Feed.suggested(current_user.id)
    render :layout => nil, :template => 'settings/suggested_feed_table'
  end
end
