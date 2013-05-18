require 'open-uri'
require 'timeout'

class GetIcon
  include Sidekiq::Worker
  sidekiq_options :queue => :icons
  attr_accessor :id
  def perform(id)
    @id = id
    feed = Feed.where(id: id).first
    return unless feed
    return if feed.feed_icon.present?
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
        # is this a base64 encoded icon?
        if html.favicon.start_with?("data:image/")
          path = "tmp/icons/#{@id}"
          File.open(path, 'wb') do|f|
            f.write(Base64.decode64(html.favicon))
          end
          return path
        end

        if test_favicon(html.favicon)
          return html.favicon
        end
        return get_root_favicon(site_url)
      end
      get_root_favicon(site_url)
    end
  rescue
    return nil
  end

  def create_icon(url)
    FeedIcon.create(:feed_id => id, :uri => url)
  end

  def get_root_favicon(site_url)
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
    status = Timeout::timeout(15) do
      r = Typhoeus.get(url, followlocation: true)
      if r.code == 200
        true
      else
        false
      end
    end
  end

  #def open(url)
  #  Typhoeus.get(url)
  #end

end
