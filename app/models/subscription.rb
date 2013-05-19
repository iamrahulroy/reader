
class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :feed
  belongs_to :source, :polymorphic => true
  belongs_to :group
  has_many :entries, :through => :items
  has_many :items, :dependent => :destroy

  # wtf?
  #has_one :feed_icon, :through => :feed, :dependent => :destroy

  before_create :set_default_name
  before_save :set_group

  validates :feed_id, :uniqueness => { :scope => :user_id,
    :message => "uniqueness violation - one subscription per user per feed or source" }

  after_update :deliver, :if => :persisted?

  default_scope {
    where(deleted: false)
  }

  def unsubscribe
    self.update_column :deleted, true
    self.items.all.each do |item|
      item.update_column :unread, false
    end
  end

  def all_items
    Item.unscoped.where(subscription_id: self.id)
  end

  def active_model_serializer
    SubscriptionSerializer
  end

  def deliver
    if Client.where(:user_id => self.user_id).count > 0
      unless delivery_in_queue?
        DeliverSubscription.perform_async(id, user_id)
      end
    end
  end

  def delivery_in_queue?
    queue = Sidekiq::Queue.new("subscriptions")
    queue.detect {|job| job.args == [id, user_id] }
  end

  def group_key
    (self.group.nil?) ? "" : self.group.parameterize
  end

  def set_group
    unless self.group_id && self.user_id
      self.group = self.user.groups.where(label: "").first
    end
  end

  def group_label
    (self.group.nil?) ? "" : self.group
  end

  def set_default_name
    if feed.nil?
      Rails.logger.info  "Feed is nil"
    else
      self[:name] = feed.name || "Untitled Feed"
    end
  end

  def self.update_counts
    find_each do |sub|
      sub.update_counts
    end
  end

  def self.destroy_invalid_subscriptions
    find_each do |sub|
      sub.destroy unless sub.valid?
    end
  end

  def update_unread_counts
    self.unread_count = Item.unscoped.where(user_id: user_id, subscription_id: id, unread: true).count
    self.save! if self.changed?
  rescue ActiveRecord::RecordInvalid
    self.destroy
  end

  def update_counts
    self.unread_count = Item.unscoped.where(user_id: user_id, subscription_id: id, unread: true).count
    self.starred_count = Item.unscoped.where(user_id: user_id, subscription_id: id, starred: true).count
    self.shared_count = Item.unscoped.where(user_id: user_id, subscription_id: id, shared: true).count
    self.commented_count = Item.unscoped.where(user_id: user_id, subscription_id: id, commented: true).count
    self.all_count = Item.unscoped.where(user_id: user_id, subscription_id: id).count
    self.save! if self.changed?
  rescue ActiveRecord::RecordInvalid
    self.destroy
  end

end
