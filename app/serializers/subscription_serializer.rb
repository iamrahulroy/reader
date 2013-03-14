class SubscriptionSerializer < ActiveModel::Serializer

  cols = Subscription.column_names
  cols.delete_if do |c|
    c.include? "password"
  end
  cols.each do |c|
    attribute c.to_sym
  end

  attribute :icon
  attribute :item_view

  def icon
    object.icon
  end

  def item_view
    object.item_view || ""
  end

end
