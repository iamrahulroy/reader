class SubscriptionSerializer < ActiveModel::Serializer

  attributes :id, :user_id, :feed_id, :group_id, :name, :weight, :unread_count, :starred_count, :shared_count, :all_count, :commented_count, :favorite, :sort, :site_url
  attribute :icon
  attribute :item_view

  def icon
    object.icon_path
  end

  def item_view
    object.item_view || ""
  end

end
