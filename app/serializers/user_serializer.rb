
class UserSerializer < ActiveModel::Serializer

  attributes :id, :name, :anonymous

  attribute :all_count
  attribute :unread_count
  attribute :starred_count
  attribute :shared_count
  #attribute :commented_count
  attribute :success
  attribute :share_to_twitter
  attribute :share_to_facebook


  #def all_count
  #  Item.where(user_id: scope.id).count
  #end
  #
  #def unread_count
  #  Item.where(user_id: scope.id, unread: true).count
  #end
  #
  #def starred_count
  #  Item.where(user_id: scope.id, starred: true).count
  #end
  #
  #def shared_count
  #  if object == scope
  #    Item.where(user_id: scope.id, shared: true).count
  #  else
  #    Item.where(user_id: scope.id, shared: true).count
  #  end
  #end
  #
  #def commented_count
  #  Item.where(user_id: scope.id, commented: true).count
  #end

  def success
    object.persisted?
  end

end

