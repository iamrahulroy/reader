class PollFeedNow < PollFeed
  sidekiq_options :queue => :poll_now
end