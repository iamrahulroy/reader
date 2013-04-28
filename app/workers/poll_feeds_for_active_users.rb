class PollFeedsForActiveUsers
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform
    self.class.perform_in(Reader::UPDATE_FREQUENCY.minutes)
    users = User.where("last_seen_at > '#{1.week.ago.to_s}'")
    ids = []
    users.each do |user|
      puts "Queuing for #{user.id} - #{user.name}"
      user = User.find(user.id)
      user.subscriptions.each do |sub|
        ids << sub.feed.id if sub.feed
      end
    end
    ap ids
    ap "#{ids.length} feeds to poll"
    ids.uniq.each do |id|
      PollFeed.perform_in(1.minute, id)
    end
  end

end
