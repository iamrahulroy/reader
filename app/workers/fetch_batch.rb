require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
class FetchBatch
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform(id)
    puts "\n\n\n\n*** Starting fetch batch\n\n\n\n\n"
    FetchSomeFeedsService.perform
    puts "\n\n\n\n*** fetch batch complete\n\n\n\n\n"

    self.class.perform_async
  end
end
