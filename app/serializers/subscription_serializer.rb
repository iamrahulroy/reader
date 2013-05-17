class SubscriptionSerializer < ActiveModel::Serializer

  attributes :id, :user_id, :feed_id, :group_id, :name, :weight, :unread_count, :starred_count, :shared_count, :all_count, :commented_count, :favorite, :sort
  attribute :icon
  attribute :item_view
  attribute :site_url

  def icon
    object.icon
  end

  def site_url
    object.site_url || ""
  end

  def item_view
    object.item_view || ""
  end

end
