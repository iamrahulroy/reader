class ItemSerializer < ActiveModel::Serializer

  attributes :id, :subscription_id, :unread, :starred, :shared, :commented, :from_id, :parent_id
  attributes :title, :author, :url, :published_at, :content, :formatted_published_at
  attributes :sent_to_twitter, :twitter_id
  attributes :sent_to_facebook, :facebook_id
  has_many :comments

  def title
    object.entry.title
  end

  def author
    object.entry.author
  end

  def url
    object.entry.url
  end

  def published_at
    object.entry.published_at
  end

  def formatted_published_at
    object.entry.published_at.to_s :short
  end

  def content
    object.entry.content
  end

  def comments
    object.all_comments
  end
end
