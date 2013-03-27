

Reader::Application.routes.draw do

  require 'sidekiq/web'

  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, :controllers => { :sessions => 'users/sessions', :registrations => "users/registrations", :passwords => "users/passwords" }

  mount JasmineRails::Engine => "/specs" unless Rails.env.production?

  get '/ping', :to => "application#newrelic"
  get '/stats', :to => "application#stats"

  get '/uploads/feed_icon/feed_icon/:id/favicon.ico', :to => "application#icon_check"

  get '/summary', :to => "application#summary"

  get '/items/counts', :to => "items#counts"
  post '/items/:id/toggle-star', :to => "items#toggle_star"

  post '/items/all', :to => "items#all"
  post '/items/unread', :to => "items#unread"
  post '/items/starred', :to => "items#starred"
  post '/items/shared', :to => "items#shared"
  post '/items/commented', :to => "items#commented"

  get "settings/your_feeds"
  get "settings/options"

  get "/people/following" => "people#following"
  get "/people/followers" => "people#followers"
  get "/people/may_know" => "people#may_know"
  post "/people/invite" => "people#invite"

  get "/auth/callback" => "users#callback", :as => "user_auth_callback"
  get "/auth/:service" => "users#authorize", :as => "user_auth"
  get "/complete-registration" => "users#complete_registration", :as => "complete_registration"
  put "/finalize" => "users#finalize"


  put "/users/:id(.json)" => "users#update"

  resources :people do
    match ":filter/items.json" => "people#items"
  end

  resources :items do
    post "tweet" => "items#tweet"
    post "facebook" => "items#facebook"
    post "items" => "items#show"
  end

  resources :subscriptions do
    match ":filter/item/:item_id/items.json" => "subscriptions#items"
    match ":filter/items.json" => "subscriptions#items"
  end

  resources :groups do
    match ":filter/items.json" => "groups#items"
  end

  resources :entries
  resources :comments

  post "share" => "share#create"



  root :to => "application#index"
  get "items/:id/show.html" => "application#index"
  get "login" => "application#index"
  get "group/:filter/:id" => "application#index"
  get "subscription/:filter/:id" => "application#index"
  get "subscription/:filter/:id/item/:item_id" => "application#index"
  get "person/:filter/:id" => "application#index"
  get "all" => "application#index"
  get "unread" => "application#index"
  get "starred" => "application#index"
  get "shared" => "application#index"
  get "commented" => "application#index"
  get "share" => "application#index"
  get "settings" => "application#index"
  get "settings/feeds" => "application#index"
  get "settings/friends" => "application#index"

  namespace :api do
    # This supports a POST with email and password to get back an auth token
    resources :tokens, :only => [:create, :destroy]
    get "authorized" => "auth#authorized"
    get "feed/subscribe" => "feeds#subscribe"
    get "share-url" => "share#url"
    get "share-content" => "share#content"
    get "links" => "links#index"
  end

  delete "subscriptions(.json)/:id" => "subscriptions#destroy"
  delete "groups(.json)/:id" => "groups#destroy"
  put "subscriptions(.json)/:id" => "subscriptions#update"
  put "groups(.json)/:id" => "groups#update"

  post "comment" => "comments#create"
  get "comments" => "comments#index"
  delete "comment/:id" => "comments#destroy"
  put "comment/:id" => "comments#update"
  get "comment/:id/editor" => "comments#editor"

  post :opml, :to => "opml#create"
  get "opml_submitted", :to => "opml#submitted"

  get  '/items/:id/email', :to => "items#email_form"
  post '/items/:id/email', :to => "items#email"

  post '/mark_read', :to => "application#mark_read"

  match '/all/items(.json)/', :to => "items#all"
  get '/items(.json)/:id', :to => "items#show"


  post "/subscribe/:id", :to => 'feeds#subscribe', :as => :subscribe

  get "/feeds/:id(.json)", :to => 'feeds#show'

  get '/settings/your_feeds', :to => "settings#your_feeds"
  get '/settings/suggested_feeds', :to => "settings#suggested_feeds"

  post "/user/follow" => "users#follow"
  post "/user/stop_following" => "users#stop_following"
  post "/user/block_follower" => "users#block_follower"
  post "/user/allow" => "users#allow"
  post "/user/reject" => "users#reject"
  post "/user/reciprocate" => "users#reciprocate"



  get "/pps" => "users#private_pub_sign_on"

  match "/receiver/:token" => "push#receiver"

end
