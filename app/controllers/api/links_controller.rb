class Api::LinksController < ApplicationController
  layout false
  before_filter :authenticate

  def index
    @links = User.charlie.items.where(starred: true).map do |item|
      {
        url: item.entry.url,
        title: "#{item.entry.title} - #{item.entry.feed.name}"
      }
    end
    respond_to do |format|
      format.html {

      }
      format.json {
        render :json => @links
      }
    end

  end

  protected
    def authenticate
      authenticate_or_request_with_http_basic do |username, password|
        username == "lemonhead" && password == "biscuits"
      end
    end

end