class DeliverSubscription
  include Sidekiq::Worker
  sidekiq_options :queue => :subscriptions
  def perform(id, user_id)
    Client.where(:user_id => user_id).each do |client|
      sub = Subscription.where(:id => id).first
      unless sub.nil?
        json = sub.active_model_serializer.new(sub).to_json(:root => false)
        begin
          PrivatePub.publish_to client.channel, "App.receiver.addSubscription(#{json})"
        rescue Errno::ECONNREFUSED
          client.destroy
        end
      end
    end
  end

end
