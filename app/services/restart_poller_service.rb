class RestartPollerService

  def self.perform
    self.new.perform
  end

  def perform
    clear_sidekiq
    clear_xml_dir

    @pushed_feeds = []
    @polled_feeds = []

    poll_feeds
  end

  def feeds
    Feed.fetchable
  end

  def clear_xml_dir
    Dir.foreach("#{Rails.root.to_s}/tmp/xmls") do |f|
      unless File.directory?(f)
        File.delete("#{Rails.root.to_s}/tmp/xmls/#{f}")
      end
    end
  end

  def clear_sidekiq
    Sidekiq.redis do |r|
      r.del("queue:poll")
      r.srem("queues", "poll")
      Sidekiq::ScheduledSet.new.clear
    end

    clear_poll_from_retries
  end

  def clear_poll_from_retries
    query = Sidekiq::RetrySet.new
    query.select do |job|
      job.klass == 'Sidekiq::Extensions::DelayedClass' &&
        # For Sidekiq::Extensions (e.g., Foo.delay.bar(*args)),
        # the context is serialized to YAML, and must
        # be deserialized to get to the original args
        ((klass, method, args) = YAML.load(job.args[0])) &&
        klass == User &&
        method == :poll_feed
    end.map(&:delete)
  end

  def poll_feeds
    self.feeds.find_each do |feed|
      PollFeed.perform_async(feed.id)
    end
  end

end