class Entry < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  include Embedder
  belongs_to :feed
  validates_presence_of :guid, :url, :published_at
  validates_uniqueness_of :guid, :scope => :feed_id

  before_save :inline_reddit, :embed_content, :ensure_pubdate, :sanitize_content
  has_many :items, :dependent => :destroy
  belongs_to :entry_guid

  before_create :create_entry_guid
  after_create :deliver

  attr_accessor :embedded

  def ensure_entry_guid_exists
    create_entry_guid unless self.entry_guid
    self.update_column(:entry_guid_id, self.entry_guid_id)
  rescue PG::Error => e
    self.destroy if e.message.include? 'duplicate key value violates unique constraint'
  end

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

  def inline_reddit
    return unless self.feed_id
    feed_url = self.feed.try(:feed_url)
    if feed_url && feed_url =~ /reddit\.com/
      content = self.content
      url = self.content.match /<a href="([^"]*)">\[link\]/

      imgmatch = url[1].match(/\.(gif|jpg|png|jpeg)(\?|#)*/i) unless url.nil?
      unless imgmatch.nil?
        unless url[1].nil?
          img = "<img src=\"#{url[1]}\" style=\"max-width:95%\"><br/>"
          content = img + self.content
          @embedded = true
        end
      end

      self.content = content

      if url && url.length > 1
        link = url[1]
        if link =~ /\/imgur\.com/
          inline_imgur link
        end

        if link =~ /\/qkme\.me/
          inline_quickmeme link
        end

        if link =~ /\/quickmeme\.com/
          inline_quickmeme link
        end
      end


    end
  end

  def embed_content
    unless @embedded
      #if self.feed.feed_url =~ /news\.ycombinator\.com\/rss/
      #  self.content = "#{self.url}<p/>#{self.content}"
      #  self.content = "#{embed_urls(self.content, false)}"
      #end

      if self.feed.feed_url =~ /reddit\.com/
        content_url = self.content.match /<a href="([^"]*)">\[link\]/
        self.content = "#{embed_urls(content_url[1],false)}\n<p/>#{self.content}" if content_url.try(:length) > 1
      end
    end
  end

  def inline_imgur(link)
    body = Faraday.get(link).body
    doc = Nokogiri::HTML(body)
    images = doc.css(".image img")
    chunk = ""
    images.each do |node|
      node.remove_attribute('class')
      chunk += node.to_s.gsub('data-src', 'src')
    end
    self.content = chunk + self.content
  rescue OpenURI::HTTPError => e

  end

  def inline_quickmeme(link)
    body = Faraday.get(link).body
    doc = Nokogiri::HTML(body)
    images = doc.css("#img")
    chunk = ""
    images.each do |node|
      node.remove_attribute('class')
      chunk += node.to_s.gsub('data-src', 'src')
    end
    self.content = chunk + self.content
  rescue OpenURI::HTTPError => e

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
    self.update_column(:delivered, true)
  end

  def deliver_to(user)
    feed = self.feed
    if feed
      subscriptions = Subscription.where(:user_id => user.id).where(:feed_id => feed.id)
      subscriptions.each do |sub|
        item = Item.new(:user_id => sub.user_id, :entry => self, :subscription => sub)

        if item.valid?
          logger.debug "save item"
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

    if site_root.present?
      while subject.match /<img.* src=['"]\// do
        subject = subject.sub /(<img.* )src=(['"])\//, "\\1src=\\2#{site_root}/"
      end

      while subject.match /<a.* src=['"]\// do
        subject = subject.sub /(<a.* )src=(['"])\//, "\\1src=\\2#{site_root}/"
      end
    end


    subject = subject.gsub /float:\s*(left|right);/,''

    subject = subject.strip

    f = subject.force_encoding("UTF-8")

    f.gsub!(/(<!--.*?-->)/, '')
    f = sanitize(f)

    self.content = f

    self.title = self.title.force_encoding("UTF-8")
    self.content_sanitized = true
    self.processed = true
  end

  protected
    def create_entry_guid
      entry_guid = EntryGuid.find_or_initialize_by_feed_id_and_guid(self.feed_id, guid)
      if entry_guid.save
        self.entry_guid_id = entry_guid.id
      else
        self.destroy if self.persisted?
      end

    end

end
