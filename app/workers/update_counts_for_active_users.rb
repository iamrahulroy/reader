class UpdateCountsForActiveUsers
  include Sidekiq::Worker
  sidekiq_options :queue => :critical
  def perform
    self.class.perform_in(Reader::UPDATE_FREQUENCY.minutes)
    users = User.where("last_seen_at > '#{1.week.ago.to_s}'").all
    users.each do |user|

      user.unread_count = user.items.where(unread: true).count
      user.starred_count = user.items.where(starred: true).count
      user.shared_count = user.items.where(shared: true).count
      user.commented_count = user.items.where(commented: true).count
      user.has_new_comments_count = user.items.where(has_new_comments: true).count
      user.all_count = user.items.count

      user.subscription_count = user.subscriptions.count

      user.save!
    end
  end

end
