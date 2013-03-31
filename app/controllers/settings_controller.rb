class SettingsController < ApplicationController
  def options
    singly_profile = Singly.singly_profile_for current_user

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

    stripe_data = JSON.load(current_user.stripe_data)

    if stripe_data && stripe_data["canceled_at"]
      @premium_account_expire_date = DateTime.strptime(stripe_data["current_period_end"].to_s,'%s').to_s(:long_ordinal)
    end


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
