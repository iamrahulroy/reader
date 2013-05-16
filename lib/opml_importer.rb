require 'libxml'
require 'uri'

module OpmlImporter

  def import_opml(xml, user_id, label=nil)
    user = User.find(user_id)
    subscriptions = []
    xml_string = xml.to_s
    doc = LibXML::XML::Document.string(xml_string)
    outline = doc.find('//outline').first
    parent = outline.parent if outline

    label = ''
    if outline.respond_to? :attributes
      if outline.name == "outline"
        if outline.attributes['xmlUrl'].nil?
          label = outline.attributes['title'] || ''
        end
      end
    end


    parent.find('outline').each do |node|
      title = node.attributes['title']
      type = node.attributes['type']
      feed_url = node.attributes['xmlUrl']
      site_url = node.attributes['htmlUrl']

      if feed_url.nil?
        self.import_opml node, user
        next
      end

      feed = Feed.find_by_feed_url(feed_url)
      if feed.nil?
        feed = Feed.find_by_feed_url(feed_url)
      end

      continue if feed_url.nil?

      if feed.nil?
        feed = Feed.create!(:name => title, :feed_url => feed_url, :site_url => site_url, :user => user)
      end

      subscription = Subscription.where("feed_id = ? AND user_id = ?", feed.id, user.id).all

      if subscription.empty?
        ap "new subscription"
        group = Group.find_or_create_by_label_and_user_id label, user.id
        Subscription.create!(:user_id => user.id, :feed_id => feed.id, :group => group)
      end

      subscriptions << subscription
    end
    Rails.logger.info "opml import complete. #{subscriptions.count}"
    subscriptions
  end


end
