
class FeedsController < ApplicationController
  def show
    @feed = Feed.find params[:id]
    render :formats => [:json]
  end

  def subscribe
    url = Feed.find(params[:id]).feed_url
    current_user.subscribe(url)
    render :text => 'ok', :layout => nil
  end
end
