class RestartPollerService

  def self.perform
    self.new.perform
  end

  def perform
    clear_sidekiq
    clear_xml_dir

    @pushed_feeds = []
    @polled_feeds = []

    puts "sleep for 1 minutes"
    #10.times do |i|
    #  puts "#{i}"
    #  sleep 1
    #end
    puts "resuming..."
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
    step = 5
    offset = 1
    self.feeds.find_in_batches do |group|
      binding.pry
      group.each do |feed|
        puts "#{offset.seconds}"
        PollFeed.perform_in(offset.seconds, feed.id)
      end
      offset = offset + step
    end
  end

end