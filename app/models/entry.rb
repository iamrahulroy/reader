class Entry < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include Embedder
  belongs_to :feed
  validates_presence_of :guid, :url, :published_at
  validates_uniqueness_of :guid, :scope => :feed_id

  before_save :ensure_pubdate

  after_save do |entry|
    if !entry.content_inlined?
      InlineContent.perform_async(entry.id)
    elsif !entry.content_embedded?
      EmbedContent.perform_async(entry.id)
    elsif !entry.content_sanitized?
      SanitizeContent.perform_async(entry.id)
    elsif !entry.delivered?
      DeliverEntry.perform_async(entry.id)
    end
  end

  has_many :items, :dependent => :destroy

  def self.share(user, title, body)
    e = Entry.new
    e.author = user.name
    e.content = body
    e.title = title
    e.feed = user.shared_feed
    e.published_at = DateTime.now
    e.parse_share

    e.guid = e.url = "http://1kpl.us/user/#{user.public_token}/shared/#{rand(36**8).to_s(36)}"

    e.save!
  end

  def parse_share
    self.content = self.embed_urls(self.content)
    self.parse_formatting
  end

  def parse_formatting
    repl = '</br>'
    self.content.gsub! /\n/, repl
  end

  def embed_content

  end

  def ensure_pubdate
    if self.published_at.nil?
      self.published_at = self.created_at
    end
  end

  def pubdate
    # TODO: figure out why some records don't have published at.
    if self.published_at.nil?
      self.published_at = self.created_at
    end
    unless self.published_at.nil?
      self.published_at.to_s :pubdate
    end
  end

  def deliver
    feed = self.feed
    if feed
      subscriptions = feed.subscriptions
      subscriptions.each do |sub|
        item = Item.new(:user_id => sub.user_id, :entry => self, :subscription => sub)
        if item.valid?
          item.save!
        end
      end

      # deliver a copy to sharing user.
      if feed.user && feed.user.shared_feed == feed
        i = Item.new
        i.entry = self
        i.shared = true
        i.unread = false
        i.user = feed.user
        i.from = feed.user
        i.save!
      end
    end
  end

  def deliver_to(user)
    feed = self.feed
    if feed
      subscriptions = Subscription.where(:user_id => user.id).where(:feed_id => feed.id)
      subscriptions.each do |sub|
        item = Item.new(:user_id => sub.user_id, :entry => self, :subscription => sub)

        if item.valid?
          puts "save item"
          item.save
        end
      end
    end
  end

  def site_root
    return unless self.feed_id
    uri = URI.parse(self.feed.site_url)
    "#{uri.scheme}://#{uri.host}"
  rescue URI::InvalidURIError => e
    ""
  end

  def sanitize_content
    # TODO: Fix broken images with site base uri if possible
    subject = content || ""
    self.title ||= ""
    while subject.match /^<br>/ do
      subject = subject.sub /^<br>/,''
    end

    while subject.match /<table>/ do
      subject = subject.sub /<table>/, '<table class="table">'
    end

    while subject.match /^<p><\/p>/ do
      subject = subject.sub /^<p><\/p>/,''
    end

    while subject.match /<img.* src=['"]\// do
      subject = subject.sub /(<img.* )src=(['"])\//, "\\1src=\\2#{site_root}/"
    end

    while subject.match /<a.* src=['"]\// do
      subject = subject.sub /(<a.* )src=(['"])\//, "\\1src=\\2#{site_root}/"
    end

    subject = subject.gsub /float:\s*(left|right);/,''

    subject = subject.strip

    f = subject.force_encoding("UTF-8")

    f.gsub!(/(<!--.*?-->)/, '')
    f = sanitize(f)

    self.content = f

    self.title = self.title.force_encoding("UTF-8")
  end

end
