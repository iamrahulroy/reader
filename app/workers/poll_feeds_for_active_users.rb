class PollFeedsForActiveUsers
  include Sidekiq::Worker
  sidekiq_options :queue => :poll
  def perform
    users = User.where("last_seen_at > '#{1.week.ago.to_s}'")
    users.each do |user|
      puts "Queuing for #{user.id} - #{user.name}"
      UpdateUserSubscriptions.perform_async(user.id)
    end
    self.class.perform_in(Reader::UPDATE_FREQUENCY.minutes)
  end

end