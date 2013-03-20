require 'open-uri'
require 'timeout'
class FilelessIO < StringIO
  attr_accessor :original_filename
end

class GetIcon
  include Sidekiq::Worker
  sidekiq_options :queue => :icons
  def perform(id)

    feed = Feed.where(id: id).first
    return unless feed
    return if feed.feed_icon.present?
    ap "FETCHING ICON for #{feed.name}"
    icon_url = get_favicon feed.site_url

    unless icon_url.nil?
      fi = FeedIcon.find_or_create_by_feed_id(id, :uri => icon_url)
      fi.uri = icon_url
      file = open fi.uri, :read_timeout => 10

      unless file.respond_to? :original_filename
        file = FilelessIO.new(file.readlines.join)
        file.original_filename = "favicon.ico"
      end

      fi.feed_icon = file
      fi.save!
    end
  end

  def get_favicon(site_url)
    unless site_url.nil?
      html = nil
      begin
        Timeout::timeout(15) do
          html = Pismo::Document.new(site_url)
        end
      rescue
        ap "pismo error - #{site_url}"
      end
      unless html.nil? || html.favicon.nil?
        if test_favicon(html.favicon)
          return html.favicon
        end
        return get_root_favicon
      end
      get_root_favicon
    end
  end

  def create_icon(url)
    FeedIcon.create(:feed_id => id, :uri => url)
  end

  def get_root_favicon
    begin
      uri = URI(site_url)
      ico = uri.scheme + "://" + uri.host + "/favicon.ico"
      if test_favicon(ico)
        return ico
      end
      png = uri.scheme + "://" + uri.host + "/favicon.png"
      if test_favicon(png)
        return png
      end
      gif = uri.scheme + "://" + uri.host + "/favicon.gif"
      if test_favicon(gif)
        return gif
      end
      return nil
    rescue
      return nil
    end
  end

  def test_favicon(url)
    begin
      status = Timeout::timeout(15) do
        r = open url
        if r.status[0] == '200'
          true
        else
          false
        end
      end
    rescue OpenURI::HTTPError => e
      ap e
      false
    rescue Timeout::Error => e
      ap e
      false
    end
  end

end
