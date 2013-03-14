class CommentSerializer < ActiveModel::Serializer

  attributes :id, :body, :html, :user_id, :author_name

  def author_name
    object.user.name
  end
end
