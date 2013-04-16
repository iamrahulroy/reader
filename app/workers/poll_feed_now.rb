class PollFeedNow < PollFeed
  sidekiq_options :queue => :poll_now

  #def process_feed(id, file_name, repeat=false)
  #  ProcessFeed.perform_async(id, file_name, repeat)
  #end
end