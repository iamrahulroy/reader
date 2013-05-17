class UsersController < ApplicationController
  skip_before_filter :check_reader_user, :only => [:callback, :complete_registration, :finalize]

  def authorize
    return unless Singly::SINGLY_SERVICES.include? params[:service].to_s
    redirect_to Singly.authentication_url_for(params[:service])
  end

  def callback
    if params[:error]
      ap "singly callback error #{params[:error]}"
      return
    end

    code = params[:code]

    Typhoeus::Config.verbose = ENV['TYPHOEUS_VERBOSE'] || false
    response = Typhoeus.post("https://api.singly.com/oauth/access_token", forbid_reuse: 1, ssl_verifypeer: false, ssl_verifyhost: 2, timeout: 60, followlocation: true, maxredirs: 5, accept_encoding: "gzip",
                                    body: '{"client_id":"'+ENV['SINGLY_CLIENT_ID']+'","client_secret":"'+ENV['SINGLY_CLIENT_SECRET']+'","code":"'+code+'","profile":"all"}',
                                    headers: {'Content-Type' => 'application/json'})

    obj = JSON.parse(response.body, {symbolize_names: true})
    # todo: finish the singly.
    # todo: create or lookup user then save account, other token ???,
    
    access_token = obj[:access_token]
    account      = obj[:account]
    email        = obj[:profile][:email]
    name         = obj[:profile][:name]

    @user = User.find_by_email(email)
    unless @user
      if account
        if real_user
          @user = current_user
        else
          @user = User.find_or_initialize_by_singly_account_id(account)
        end
      else
        @user = User.new
      end
    end

    if @user.persisted? && @user.email == email && email
      @user.singly_access_token = access_token
      @user.singly_account_id   = account
      @user.save!
      sign_in_and_redirect @user, :event => :authentication
    else
      @user.email               = email
      @user.name                = name
      @user.singly_access_token = access_token
      @user.singly_account_id   = account
      @user.password = @user.password_confirmation = rand(36**7..36**16).to_s(36)

      if @user.email.present?
        if @user.save
          sign_in_and_redirect @user, :event => :authentication
        else
          flash[:error] = "Authentication failed"
          redirect_to root_path
        end
      else
        @user.save(validate: false)
        session[:incomplete_user_id] = @user.id
        redirect_to :complete_registration
      end
    end
  end

  def complete_registration
    id = session[:incomplete_user_id]
    @user = User.find(id)
    render "complete_registration", :layout => false
  end

  def finalize
    id = session[:incomplete_user_id]
    @user = User.find(id)
    @user.email                 = params[:user][:email]
    @user.password              = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]
    if @user.valid? && @user.save!
      sign_in('user', @user)
      @user.send_welcome_email
      redirect_to "/settings"
    else
      render "complete_registration", :layout => false
    end
  end

  def follow
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.follow(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def stop_following
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.stop_following(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def block_follower
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.block(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def allow
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.unblock(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def reciprocate
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.unblock(target_user) unless target_user.nil?
    current_user.follow_and_unblock(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def reject
    return unless real_user
    target_user = User.find(params[:user_id])
    current_user.ignore_requests_from(target_user) unless target_user.nil?
    render :text => "Success", :layout => nil
  end

  def private_pub_sign_on
    if real_user
      render :layout => nil
    else
      head :ok
    end
  end

  def update
    return unless real_user

    current_user.share_to_twitter = params[:share_to_twitter]
    current_user.share_to_facebook = params[:share_to_facebook]
    ap params
    current_user.save!

    head :ok
  end

end
