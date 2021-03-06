class Feed < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  has_one :feed_icon, :dependent => :destroy
  #has_many :subscriptions, :dependent => :destroy
  has_many :subscriptions, :as => :source, :dependent => :destroy
  has_many :entries, :as => :source, :dependent => :destroy
  belongs_to :user
  validates :feed_url, :uniqueness => true

  before_create :set_tokens, :strip_name
  before_save :scrub
  before_validation :merge
  after_create :poll_feed, :get_icon
  after_commit :sweep
  scope :fetchable, where(:fetchable => true).where(:private => false)
  scope :fetched, where('fetch_count > 0')
  scope :failed, where('connection_errors > 0 or parse_errors > 0 or feed_errors > 0')
  scope :unfetchable, where(:fetchable => false)
  #scope :suggested, where(:suggested => true)

  after_save :set_fetchable

  def set_fetchable
    if feed_errors > 5 || parse_errors > 5
      self.update_column(:fetchable, false)
    end
  end

  def update_subscriptions
    # This needs to be run after the feed icon or site url is updated.
    icon_path = (feed_icon) ? feed_icon.local_path : nil
    subscriptions.each do |sub|
      sub.update_column :site_url, self.site_url
      sub.update_column :icon_path, icon_path
    end
  end

  def total_errors
    connection_errors + parse_errors + fetch_errors
  end

  def self.suggested(uid)
    user = User.find uid
    fids = user.subscriptions.where(:source_type => 'Feed').pluck(:source_id)
    feeds = []
    self.where(:suggested => true).all.each do |f|
      feeds << f unless fids.include? f.id
    end
    feeds
  end

  def strip_name
    self.name ||= "no title"
    self.name.strip!
  end

  def scrub
    name = sanitize(name)
    description = sanitize(description)
  end

  def set_tokens
    self.token = rand(36**20).to_s(36)
    self.secret_token = rand(36**40).to_s(36)
  end

  def self.get_icons
    find_each do |f|
      f.get_icon
    end
  end

  def get_icon
    GetIcon.perform_async(id) if fetchable? && public?
  end

  def poll_feed
    PollFeed.perform_async(id) if fetchable? && public?
  end

  def push_enabled?
    hub.present? && topic.present?
  end

  def public?
    !private?
  end

  private

  def sweep
    self.delete if self.feed_url.start_with?("delete - ")
  end

  def merge
    return unless feed

    self.subscriptions.update_all(source_id: feed.id)

    Entry.order("id ASC").where(source_id: self.id).each do |entry|
      other = Entry.where(source_id: feed.id, source_type: 'Feed').where(guid: entry.guid).first
      if other
        entry.items.update_all(entry_id: other.id)
        entry.delete
      end
    end

    self.entries.update_all(source_id: feed.id)

    EntryGuid.where(source_id: id, source_type: 'Feed').delete_all
    FeedIcon.where(feed_id: id).destroy_all

    self.feed_url = "delete - #{SecureRandom.hex}" # allow the save to go through by setting feed_url to a unique value
  end

  def feed
    return unless self.feed_url.present? && self.id
    Feed.order("id ASC").where(:feed_url => self.feed_url).where("id != #{self.id}").first
  end

end
