# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'selenium/webdriver/remote/http/curb'
require 'rspec/rails'
require 'capybara/rails'
require 'vcr'
require 'sidekiq/testing'
require 'faraday'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f }

RSpec.configure do |config|

  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |config|
  config.cassette_library_dir = "#{Rails.root}/spec/support/vcr_cassettes"
  config.hook_into :faraday
  config.ignore_localhost = true
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  config.include Devise::TestHelpers, :type => :controller
  config.include TestHelpers
  DatabaseCleaner.strategy = :truncation

  config.before :each do
    DatabaseCleaner.clean
    ActionMailer::Base.deliveries = []
    Capybara.reset_sessions!
  end

  config.after :each do
    rspec_reset
    clear_jobs
    Capybara.reset_sessions!    # Forget the (simulated) browser state
    Capybara.use_default_driver # Revert Capybara.current_driver to Capybara.default_driver
  end

end
