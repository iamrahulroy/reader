require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
class FetchBatch
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform
    puts "\n\n\n\n*** Starting fetch batch\n\n\n\n\n"

    ids = Feed.fetchable.order("fetch_count ASC").pluck(:id)
    FetchSomeFeedsService.perform(ids)
    puts "\n\n\n\n*** fetch batch complete\n\n\n\n\n"

    self.class.perform_async
  end
end
