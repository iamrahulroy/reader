class UpdateItem
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform(params)
    params.symbolize_keys!
    item = Item.find params[:id]
    item.unread = params[:unread]
    item.starred = params[:starred]
    item.shared = params[:shared]
    item.has_new_comments = params[:has_new_comments]

    item.save!
    item.after_user_item_update
    item.update_subscription_count
  end
end