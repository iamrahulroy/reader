class ItemsController < ApplicationController
  before_filter :authenticate_user!
  def index
    offset = params[:offset]
    offset ||= 0
    if real_user
      @items = Item.for(current_user.id).offset(offset).includes(:subscription).limit(Reader::GET_ITEM_BATCH_COUNT)
    else
      @items = Item.for(current_user.id).where("created_at > ?", Time.now - 7.days)
    end
    render :json => @items, :each_serializer => ItemSerializer, :root => false
  end

  def counts
    unread = current_user.unread_count
    starred = current_user.starred_count
    shared = current_user.shared_count
    commented = current_user.commented_count
    has_new_comments = current_user.has_new_comments_count
    all = current_user.all_count
    subs = current_user.subscription_count

    render :json => {
      unread_count: unread,
      starred_count: starred,
      shared_count: shared,
      commented_count: commented,
      has_new_comments_count: has_new_comments,
      all_count: all,
      subscription_count: subs
    }
  end

  def tweet
    return if anonymous_user
    item = Item.find params[:item_id]
    return unless current_user.id == item.user_id
    Singly.tweet_item(current_user, item)
    render :json => item, :serializer => ItemSerializer, :root => false
  end

  def facebook
    return if anonymous_user
    item = Item.find params[:item_id]
    return unless current_user.id == item.user_id
    Singly.facebook_item(current_user, item)
    render :json => item, :serializer => ItemSerializer, :root => false
  end

  def all
    @items = current_user.items.limit(Reader::GET_ITEM_BATCH_COUNT).order("entries.published_at DESC")
    exclude_ids
    render_items
  end

  def unread
    @items = user_items(:unread)
    exclude_ids
    render_items
  end

  def starred
    @items = user_items(:starred)
    exclude_ids
    render_items
  end

  def shared
    @items = user_items(:shared)
    exclude_ids
    render_items
  end

  def commented
    @items = current_user.items.filter(:commented).limit(Reader::GET_ITEM_BATCH_COUNT).order("updated_at DESC")
    exclude_ids

    current_user.items.where(has_new_comments: true).update_all(has_new_comments: false)
    render_items
  end

  def show
    item = Item.find(params[:item_id])
    render :json => [item], :each_serializer => ItemSerializer, :root => false
  end

  def update
    head(:ok) and return if current_user.anonymous
    item = current_user.items.where(id: params[:id]).first
    item.unread = params[:unread]
    item.starred = params[:starred]
    item.shared = params[:shared]
    item.has_new_comments = params[:has_new_comments]

    item.save!
    item.after_user_item_update
    item.update_subscription_count
    head :ok
  end

  def email_form
    return if current_user.anonymous
    @item = Item.find(params[:id])
    render :layout => nil
  end

  def email
    return if current_user.anonymous
    item = Item.find(params[:id])
    user = current_user
    to = params[:to]
    subject = params[:subject]
    body = params[:body]

    email = {:item => item,:user => user,:to => to, :subject => subject, :body => body}
    ItemMailer.item(email).deliver

    render :json => {:success => "sent!"}
  end

  def toggle_star
    return if current_user.anonymous
    ap params
    item = Item.find(params[:id])
    ap item
    item.starred = !item.starred
    item.save!
    render :json => item, :serializer => ItemSerializer, :root => false
  end

  protected
    def exclude_ids
      ids = params[:ids]
      if ids
        ids = ids.map {|id| id.to_i }.join(',')
        @items = @items.where("items.id not in (#{ids})")
      end
    end

    def user_items(filter)
      current_user.items.filter(filter).limit(Reader::GET_ITEM_BATCH_COUNT).order("entries.published_at DESC")
    end

    def render_items
      render :json => @items, :each_serializer => ItemSerializer, :root => false
    end

end
