require 'acts_as_follower'
class User < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable,
    :recoverable, :rememberable, :trackable, :validatable, :remember_for => 3.months

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :name, :password, :password_confirmation, :remember_me, :anonymous, :registration_complete, :agree_to_terms

  acts_as_followable
  acts_as_follower

  after_save :check_user_registration_state

  after_save :sanitize_name


  before_save :ensure_websocket_token, :ensure_public_token, :touch_last_seen_at

  belongs_to :shared_feed, :class_name => "Feed"
  belongs_to :starred_feed, :class_name => "Feed"
  has_one :client, :dependent => :destroy

  has_many :feeds, :through => :subscriptions
  has_many :subscriptions, :dependent => :destroy, :conditions => "deleted = 'f'"
  has_many :deleted_subscriptions, :class_name => "Subscription", :conditions => "deleted = 't'"
  has_many :favorite_subscriptions, :class_name => "Subscription", :conditions => "favorite = 't'", :order => "name ASC"
  has_many :items, :dependent => :destroy
  has_many :comments, :dependent => :destroy

  has_many :groups, :dependent => :destroy

  validates_presence_of :email

  scope :recent_visitors, where("last_seen_at > ?", 1.week.ago)

  scope :active, where("premium_account = ? or free_account = ? or created_at > ?", true, true, 3.weeks.ago)

  def paid?
    self.premium_account? || self.free_account?
  end

  def active?
    self.premium_account? || self.free_account? || self.created_at > 3.weeks.ago
  end

  def check_user_registration_state
    self.update_attribute(:registration_complete, true) if self.valid? && !registration_complete?

    if self.registration_complete? && !self.anonymous? && self.valid?
      unless has_root_group? # they need to get the default feed set and the welcome email
        make_root_group
        copy_anonymous_feeds
      end
      create_starred_item_feed unless self.starred_feed.present?
      create_shared_item_feed unless self.shared_feed.present?
    end
  end

  def recent_starred_items
    items.where(starred: true).order("updated_at DESC").limit(8).all
  end

  def recent_shared_items
    items.where(shared: true).order("updated_at DESC").limit(8).all
  end

  def active_model_serializer
    UserSerializer
  end

  def copy_anonymous_feeds
    User.anonymous.subscriptions.each do |sub|
      grp = Group.find_or_create_by_label_and_user_id(sub.group.label, self.id)
      sub2 = Subscription.new(:user_id => self.id, :source_id => sub.source.id, :source_type => 'Feed', :group => grp, :name => sub.source.name)
      sub2.save!
    end
    NewUserSetup.perform_async(self.id)
  end

  def set_weights
    set_group_weights
    set_subscription_weights
  end

  def set_subscription_weights
    # alpha sort the feeds if this is the first time to set weights
    weights = self.subscriptions.pluck(:weight)
    sub_order =  "weight ASC"
    sub_order = "lower(name) ASC" if weights.uniq.length == 1
    weight = 0
    self.subscriptions.order(sub_order).each do |sub|
      weight = weight + 100
      sub.update_column(:weight, weight) unless sub.weight == weight
    end
  end

  def set_group_weights
    weight = 0
    self.groups.order("weight ASC").each do |grp|
      weight = weight + 100
      grp.update_column(:weight, weight) unless grp.weight == weight
    end
    self.groups.where("label = ''").each do |grp|
      weight = weight + 100
      grp.update_column(:weight, weight) unless grp.weight == weight
    end
  end

  def create_shared_item_feed
    create_user_item_feed :shared
  end

  def create_starred_item_feed
    create_user_item_feed :starred
  end

  def has_root_group?
    Group.where(:user_id => self.id, :label => "").count > 0
  end

  def make_root_group
    Group.create!(:user_id => self.id, :label => "")
  end

  def root_group
    self.groups.where(:label => "").first
  end

  def ensure_public_token
    if self.public_token.nil?
      self.public_token = rand(36**8).to_s(36)
    end
  end

  def ensure_websocket_token
    if self.websocket_token.nil?
      self.websocket_token = rand(36**8).to_s(36)
    end
  end

  def send_welcome_email
    PlusMailer.welcome(self).deliver
  end

  def ensure_token!
    @user.ensure_authentication_token!
  end

  def sanitize_name
    clean_name = sanitize(self.name)
    self.update_column :name, clean_name
  end

  def followed_people
    self.all_follows.collect do |f|
      {:id => f.followable_id, :name => User.find(f.followable_id).name}
    end
  end

  def friends
    self.all_following
  end

  def unblock(user)
    Follow.where(:followable_id => self.id).where(:follower_id => user.id).each do |f|
      f.blocked = false
      f.save
    end
  end

  def follow_requests
    Follow.where(:followable_id => self.id).where(:blocked => true).where(:ignored => false).all.map(&:follower)
  end

  def follow_and_unblock(user)
    self.follow user
    user.unblock self
  end

  def ignore_requests_from(user)
    Follow.where(:followable_id => self.id).where(:follower_id => user.id).each do |f|
      f.ignored = true
      f.save
    end
  end

  def subscribe(url, group=nil)
    feed = Feed.where(feed_url: url).first
    if feed
      sub = self.subscriptions.where(source_id: feed.id, source_type: 'Feed').first_or_create!
      sub.group = group if group
      sub.save!
      sub
    else
      result = DiscoverFeedService.discover(url)
      if result.length == 1
        result = result.first
        fz = Feedzirra::Feed.fetch_and_parse result.href
        feed = Feed.where(feed_url: result.href).first_or_create!(name: result.title, site_url: fz.url)
        sub = self.subscriptions.where(source_id: feed.id, source_type: 'Feed').first_or_create!
        sub.group = group if group
        sub.save!
        sub
      elsif result.length > 1
        {:feeds => feeds}
      else
        {:error => "No RSS or Atom feeds found for #{url}"}
      end
    end
  end

  def admin?
    id == 2
  end

  def self.anonymous
    User.unscoped.where(email: 'anonymous@1kpl.us').first_or_create!(name: 'none', password: SecureRandom.hex, anonymous: true, registration_complete: true, email: 'anonymous@1kpl.us')
  end
  def self.charlie
    User.where(email: "charlie@example.com").first_or_create!(name: 'Charlie', password: '123123', registration_complete: true, email: "charlie@example.com")
  end
  def self.loren
    User.where(email: "loren@example.com").first_or_create!(name: 'none', password: '123123', registration_complete: true, email: "loren@example.com")
  end
  def self.josh
    User.where(email: "josh@example.com").first_or_create!(name: 'none', password: '123123', registration_complete: true, email: "josh@example.com")
  end
  def self.steve
    User.where(email: "steve@example.com").first_or_create!(name: 'none', password: '123123', registration_complete: true, email: "steve@example.com")
  end

  protected

    def create_user_item_feed(type)
      f = Feed.new
      f.name = "Posts #{type} by #{self.name}"
      f.feed_url = "http://1kpl.us/user/#{self.public_token}/#{type}"
      f.site_url = "http://1kpl.us/"
      f.user = self
      f.private = true
      f.fetchable = false
      f.save!
      self.update_column "#{type}_feed_id", f.id
    end

    def touch_last_seen_at
      if self.new_record?
        self.last_seen_at = DateTime.now
      else
        self.touch(:last_seen_at)
      end
    end

end
