class Api::FeedsController < ApplicationController

  def subscribe
    if real_user
      url = params[:url]

      feeds = DiscoverFeedService.discover(url)
      if feeds.length == 0
        result = {:error => "No RSS or Atom feeds found for #{url}"}
      elsif feeds.length == 1
        subscription = current_user.subscribe(feeds.first.href)
        result = {:subscriptions => [subscription]}
      elsif feeds.length > 1
        result = {:feeds => feeds}
      end


      @result = result

      respond_to do |format|
        format.html {
          if result[:subscriptions]
            flash[:notice] = "You have subscribed to #{@result[:subscriptions].map(&:name).join(', ')}"
            redirect_to "/"
          end
        }
        format.js {
          render :json => @result, :layout => nil
        }
      end
    else
      redirect_to "/login?d=#{CGI.escape(request.env["REQUEST_URI"])}"
    end
  end

end
