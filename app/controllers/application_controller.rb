class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_reader_user, :do_not_cache, :except => :newrelic
  include ApplicationHelper

  def newrelic
    render :text => "OK"
  end

  def stats
    redirect_to "/login" unless current_user && current_user.admin?
    @user_count = User.unscoped.count - 1 # anonymous user
    @item_count = Item.unscoped.count
    @sub_count  = Subscription.unscoped.count
    @feed_count = Feed.unscoped.count
    @client_count = Client.unscoped.count
    index_setup
    render :content_type => "text/html"
  end

  def index
    index_setup
    render :content_type => "text/html"
  end

  def summary
    @favorites = current_user.favorite_subscriptions
    cards = 6
    x = [cards-current_user.favorite_subscriptions.count, cards].min
    x = [x, 0].max
    @subscriptions = current_user.subscriptions.where(favorite: false).order("unread_count DESC").first(24).sample(x)
    @starred = current_user.recent_starred_items
    @shared = current_user.recent_shared_items
    render "summary", :layout => nil
  end

  def mark_read
    return if current_user.anonymous
    id = params[:id]
    case params[:streamType]
      when "subscription"
        sub = Subscription.find(id)
        Item.unscoped.where(user_id: current_user.id).where(subscription_id: sub.id).update_all(unread: false)
        sub.update_counts
      when "group"
        grp = Group.find(id)
        grp.subscriptions.each do |sub|
          Item.unscoped.where(user_id: current_user.id).where(subscription_id: sub.id).update_all(unread: false)
          sub.update_counts
        end
      when "person"
        person = User.find(id)
        Item.unscoped.where(user_id: current_user.id).where(from_id: person.id).update_all(unread: false)
    end
    head :ok
  end

  def icon_check
    head :ok
  end

  private

    def index_setup
      #check_reader_user
      @user_json = render_to_string :json => current_user, :serializer => UserSerializer, :root => false
      if real_user
        get_follower_requests
        if current_user.last_seen_at < 1.minutes.ago
          UpdateUserSubscriptions.perform_async(current_user.id)
        end
        touch_user
      end
    end

    def check_reader_user
      unless real_user
        sign_in(:user, User.anonymous)
      end
    end

    def get_follower_requests
      unless real_user.nil?
        @follow_requests = current_user.follow_requests
      end
    end

    def do_not_cache
      response.headers["Pragma"] = "no-cache"
      response.headers["Cache-Control"] = "no-cache"
    end

    def set_weights
      current_user.set_weights if real_user
    end

    def touch_user
      if real_user
        current_user.touch(:last_seen_at)
      end
    end

end
