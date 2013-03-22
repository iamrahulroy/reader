class Singly
  SINGLY_SERVICES = %w(facebook twitter)

  class << self
    def authentication_url_for(service)
      scopes = ""
      scopes = "&scope=email,publish_actions" if service == "facebook"
      "https://api.singly.com/oauth/authenticate?client_id=#{ENV['SINGLY_CLIENT_ID']}&service=#{service}#{scopes}&redirect_uri=http://1kpl.us/auth/callback"
    end

    def singly_profile_for(user)
      if user.singly_access_token
        response = get("https://api.singly.com/profile?access_token=#{user.singly_access_token}")
        Oj.load(response.body)
      end
    end

    def facebook_home_for(user)
      response = get("https://api.singly.com/services/facebook/feed?access_token=#{user.singly_access_token}")
      Oj.load(response.body)
    end

    def friends_for(user)
      response = get("https://api.singly.com/friends/all?sort=interactions&access_token=#{user.singly_access_token}")
      Oj.load(response.body)
    end

    def share_item(user, item)
      return unless Rails.env.development? || Rails.env.production?
      share_to_services = []
      share_to_services << "facebook" if user.share_to_facebook
      share_to_services << "twitter" if user.share_to_twitter
      # singly posting to services
      if share_to_services.length > 0
        response = post("https://api.singly.com/types/news?access_token=#{user.singly_access_token}&to=#{share_to_services.join(',')}&url=#{item.url}")
        ap response
        response
      end
    #  TODO: update item props sent_to_:service and :service_id
    end

    def tweet_item(user, item)
      return unless Rails.env.production?
      response = post("https://api.singly.com/types/news?access_token=#{user.singly_access_token}&to=twitter&body=#{item.url}")
      json = Oj.load(response.body)
      id = json["twitter"]["id"]
      item.update_attribute(:sent_to_twitter, true)
      item.update_attribute(:twitter_id, id)
      response
    end

    def facebook_item(user, item)
      return unless Rails.env.production?
      response = post("https://api.singly.com/types/news?access_token=#{user.singly_access_token}&to=facebook&url=#{item.url}")
      json = Oj.load(response.body)
      id = json["facebook"]["id"]
      item.update_attribute(:sent_to_facebook, true)
      item.update_attribute(:facebook_id, id)
      response
    end

    private

      def image_url?(url)
        url.match(/\.(gif|jpg|png|jpeg)(\?|#)*/i)
      end

      def action_for_url(url)
        image_url?(url) ? :photos : :news
      end

      def key_for_url(url)
        image_url?(url) ? :photo : :url
      end

      def post(url, body = nil)
        conn = Faraday.new(:url => url) do |c|
          c.adapter Faraday.default_adapter
        end
        response = conn.post do |request|
          request.body = body if body
        end
        response
      end

      def get(url)
        conn = Faraday.new(:url => url) do |c|
          c.adapter Faraday.default_adapter
        end
        response = conn.get
        response
      end
  end

end