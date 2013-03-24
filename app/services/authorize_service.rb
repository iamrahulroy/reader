class AuthorizeService

  attr :auth_code

  attr_reader :access_token, :account, :email, :name

  def initialize(auth_code)
    @auth_code = auth_code
  end

  def perform
    auth_obj = get_authorization
    @access_token = auth_obj[:access_token]
    @account      = auth_obj[:account]
    @email        = auth_obj[:profile][:email]
    @name         = auth_obj[:profile][:name]
    self
  end

  protected

  def get_authorization
    conn = Faraday.new(:url => "https://api.singly.com/oauth/access_token") do |c|
      c.response :follow_redirects
    end

    response = conn.post do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = '{"client_id":"'+ENV['SINGLY_CLIENT_ID']+'","client_secret":"'+ENV['SINGLY_CLIENT_SECRET']+'","code":"'+auth_code+'","profile":"all"}'
    end

    obj = JSON.parse(response.body, {symbolize_names: true})
    ap obj
    obj
  end

end