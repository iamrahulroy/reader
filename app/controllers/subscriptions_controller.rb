class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @subscriptions = Subscription.where(:user_id => current_user.id).order("weight DESC")
    render :json => @subscriptions, :each_serializer => SubscriptionSerializer, :root => false
  end

  def show
    @subscription = Subscription.find(params[:id])
    render :json => @subscription, :serializer => SubscriptionSerializer, :root => false
  end

  def items
    sub = Subscription.find params[:subscription_id]
    return unless current_user == sub.user
    item_id = params[:item_id].to_i if params[:item_id]

    @items = Item.unscoped.where(user_id: current_user.id, subscription_id: sub.id)
    unless params[:filter] == "all"
      @items = @items.where(params[:filter] => true)
    end
    @items = @items.limit(Reader::GET_ITEM_BATCH_COUNT).includes(:feed, :entry, :comments)

    if item_id
      @items = @items.order("items.id = #{item_id} DESC, created_at DESC")
    else
      @items = @items.order("created_at DESC")
    end

    ids = params[:ids]
    if ids
      ids = ids.map {|id| id.to_i }.join(',')
      @items = @items.where("id not in (#{ids})")
    end
    @items = @items.all

    item = @items.shift if item_id
    @items.sort! {|a,b| b.entry.published_at <=> a.entry.published_at }
    @items.unshift item if item_id


    render :json => @items, :each_serializer => ItemSerializer, :root => false
  end

  def create
    return if anonymous_user
    feeds = params[:feeds]
    if feeds.present?
      results = []
      feeds.each do |feed|
        subscription = current_user.subscribe(feed.href)
        results << subscription
      end
      results = {:subscriptions => results}
      render :json => results, :layout => nil
    else
      feed_url = params[:feed_url]
      feeds = DiscoverFeedService.discover(feed_url)
      if feeds.length == 0
        result = {:error => "No RSS or Atom feeds found for #{feed_url}"}
      elsif feeds.length == 1
        subscription = current_user.subscribe(feeds.first.href)
        result = {:subscriptions => [subscription]}
      elsif feeds.length > 1
        result = {:feeds => feeds}
      end
      @result = result
      render :json => @result, :layout => nil
    end
  end

  def destroy
    return if anonymous_user
    sub = Subscription.where(:user_id => current_user.id).find(params[:id])
    return unless current_user.id == sub.user_id
    sub.unsubscribe
    render :json => {:success => true}
  end

  def update
    return if current_user.anonymous
    sub = Subscription.find(params[:id])
    return unless current_user.id == sub.user_id
    sub.name = params[:name]
    sub.group_id = params[:group_id]
    sub.weight = params[:weight]
    sub.item_view = params[:item_view]
    sub.favorite = params[:favorite]
    sub.save
    @subscription = sub
    render :json => @subscription, :serializer => SubscriptionSerializer, :root => false
  end
end
