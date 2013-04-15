source "https://rubygems.org"
gem "feedzirra", git: "https://github.com/pauldix/feedzirra.git"
gem "nokogiri", "~> 1.5"
gem "rails", "~> 3.2"
gem "unicorn", "~> 4.4", :require => false
gem "god", "~> 0.13"

gem "sidekiq", "~> 2.6"
gem "sidekiq-failures", "~> 0.1"
gem 'sidekiq-unique-jobs'

gem "sinatra", "~> 1.3", :require => false
gem "slim", "~> 1.3", :require => false
gem "thin", "~> 1.5", :require => false

gem "pg", "~> 0.15"
gem "devise", "~> 2.2"
gem "acts_as_follower", "~> 0.1"

gem "muck-feedbag", git: "https://github.com/1kplus/feedbag.git"

gem "hpricot", "~> 0.8"
gem "private_pub", "~> 1.0"
gem "libxml-ruby", "~> 2.3"
gem "curb", "~> 0.8"
gem "typhoeus", "~> 0.5"
gem "faraday", "~> 0.8"
gem "faraday_middleware", "~> 0.9"
gem "embedly", "~> 1.5"
gem "haml", "~> 4.0"
gem "active_model_serializers", "~> 0.6"
gem "oj", "~> 2.0"
gem "loofah", "~> 1.2"
gem "ensure-encoding", "~> 0.1"
gem "pismo", "~> 0.7"
gem "carrierwave", "~> 0.8"
gem "capistrano", "~> 2.0"
gem "rvm-capistrano", "~> 1.2"
gem "figaro", "~> 0.6"

gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

gem "pry-rails", "~> 0.2"
gem "pry-coolline"
gem "pry-debugger"
gem "pry-remote"

group :production do
  gem "newrelic_rpm", "~> 3.5"
end

group :development do
  gem "binding_of_caller", "~> 0.7"
  gem "better_errors", "~> 0.6"
  gem "meta_request", "~> 0.2"
  gem "erb2haml", "~> 0.1"
  gem "mails_viewer", "~> 0.0"
  gem "foreman", "~> 0.61"
end

group :test, :development do
  gem "ruby_gntp"
  gem "awesome_print" #, "~> 1.1"
  gem "rspec-rails" #, "~> 2.12"
  gem "quiet_assets" #, "~> 1.0"
  #gem "jasmine-rails" #, "~> 0.3"
  gem "marginalia"
end

group :test do
  gem "timecop"
  gem "selenium-webdriver"
  gem "database_cleaner" #, "~> 0.9"
  gem "capybara" #, "~> 2.0"
  gem "vcr" #, "~> 2.4"
  gem "launchy" #, "~> 2.2"
end

group :assets do
  gem "visibilityjs"
  gem "jquery-rails", "~> 2.2"
  gem "sass-rails", "~> 3.2"
  gem "bootstrap-sass", "~> 2.3"
  gem "coffee-rails", "~> 3.2"
  gem "compass-rails", "~> 1.0"
  gem "handlebars_assets", " ~> 0.10"
  gem "uglifier", "~> 1.3"
  gem "turbo-sprockets-rails3", "~> 0.3"
end
