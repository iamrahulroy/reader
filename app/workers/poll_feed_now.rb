class PollFeedNow < PollFeed
  sidekiq_options :queue => :clients
end