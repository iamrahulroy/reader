
namespace :reader do

  desc "Fetch all the feeds, ALL OF THEM"
  task :fetch_all => :environment do
    puts "\n\n\n\n*** Starting fetch_all\n\n\n\n\n"
    ids = Feed.fetchable.order("fetch_count ASC").limit(1000).pluck(:id)
    FetchSomeFeedsService.perform(ids)
    puts "\n\n\n\n*** fetch complete\n\n\n\n\n"
  end

  desc "reset feed error counts"
  task :reset_feed_errors => :environment do
    Feed.update_all parse_errors: 0, timeouts: 0, fetchable: true, etag: nil, hub: nil, topic: nil, connection_errors: 0, feed_errors: 0, fetch_count: 0
  end

  desc "poll feeds for new posts"
  task :run_poller => :environment do
    RestartPollerService.perform
  end

  desc "poll feeds for active users"
  task :run_poller_for_active_users => :environment do
    users = User.where("last_seen_at > '#{1.week.ago.to_s}'")
    users.each do |user|
      puts "Queuing for #{user.id} - #{user.name}"
      UpdateUserSubscriptions.perform_async(user.id)
    end
  end


  namespace :redis do
    desc "redis - remove all keys from all databases"
    task :flushall => :environment do
      Sidekiq.redis do |r|
        r.flushall
      end
    end
  end

  desc "set subscription count on feeds"
  task :update_feed_subscription_count => :environment do
    Feed.find_each do |feed|
      c = feed.subscriptions.count
      puts "#{feed.name} - #{c} subscriptions"
      feed.update_column :subscription_count, c
    end
  end

  namespace :fix do
    desc "fix entries without published_at dates"
    task :entry_published_dates => :environment do
      Entry.where(published_at: nil).find_each do |e|
        e.published_at = e.created_at
        e.save!
      end
    end

    desc "fix entries without entry_guids"
    task :entry_guids => :environment do
      Entry.where(entry_guid_id: nil).find_each do |e|
        puts "ensure_entry_guid_exists: #{e.id} - #{e.title}"
        e.ensure_entry_guid_exists
      end
    end

    desc "sanitize all entries"
    task :entry_sanitization => :environment do
      Entry.find_each do |e|
        puts "Sanitizing #{e.id} - #{e.title}"
        e.save!
      end
    end
  end

  desc "fetch feed favicons"
  task :icons => :environment do
    Feed.get_icons
  end

  desc "prune old items that are no longer needed"
  task :prune_items => :environment do
    Reader::Setup.prune_items
  end

  desc "update anonymous user feeds"
  task :anonymous => :environment do
    Reader::Setup.update_anon_feeds
  end

  desc "seed application"
  task :seed => :environment do
    Reader::Setup.seed
  end

  desc "scrub application"
  task :scrub => :environment do
    Entry.destroy_all
    Item.destroy_all
    EntryGuid.destroy_all
    FeedIcon.destroy_all
    Comment.destroy_all
    Client.destroy_all
    `rm -rf public/uploads/*`
  end

  desc "reset fetchable, parse errors, timeouts"
  task :feed_reset_errors => :environment do
    Feed.all.each do |f|
      f.fetchable = true
      f.timeouts = 0
      f.parse_errors = 0
      f.save
    end
  end

  desc "### TEST: Marks all items read but one for each subscription"
  task :all_but_one => :environment do
    Item.update_all unread: false
    User.charlie.subscriptions.each do |sub|
      item = sub.items.first
      item.update_column(:unread, true) if item
    end
    Subscription.update_counts
  end

  desc "init EntryGuids"
  task :init_entry_guids => :environment do
    Entry.all.each do |entry|
      eg = EntryGuid.find_or_initialize_by_feed_id_and_guid(entry.feed_id, entry.guid)
      if eg.new_record?
        eg.save
      end
    end
  end


end

