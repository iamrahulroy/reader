class SubscriptionSerializer < ActiveModel::Serializer

  cols = Subscription.column_names
  cols.each do |c|
    attribute c.to_sym
  end

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
