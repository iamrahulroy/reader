class ShareItem
  include Sidekiq::Worker
  sidekiq_options :queue => :items
  def perform(id)
    item = Item.find id
    user = item.user

    user.followers.each do |follower|
      new_item = Item.new(user_id: follower.id, entry_id: item.entry_id, subscription_id: item.subscription_id, parent_id: item.id, from_id: user.id)
      new_item.from_id = user.id
      new_item.save!
    end

    #Singly.share_item(user, item)
    item.update_column :share_delivered, true
  #rescue ActiveRecord::RecordNotUnique => e

  end

end