class DeliverComment
  include Sidekiq::Worker
  sidekiq_options :queue => :comments
  def perform(comment_id)
    comment = Comment.find comment_id
    item = comment.item

    unless item.has_new_comments?
      item.has_new_comments = true
      item.save!
    end

    user = comment.user
    user.all_following.each do |follower|
      Client.where(:user_id => follower.id).each do |client|
        # todo use the serializer
        json = comment.active_model_serializer.new(comment).to_json(:root => false)

        begin
          PrivatePub.publish_to client.channel, "App.receiver.addComment(#{json})"
        rescue Errno::ECONNREFUSED
          client.destroy
        end
      end
    end
  end

end