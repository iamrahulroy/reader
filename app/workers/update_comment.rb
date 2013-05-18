class UpdateComment
  include Sidekiq::Worker
  sidekiq_options :queue => :comments
  def perform(comment_id)
    puts "update comment - #{comment_id}"
    comment = Comment.find comment_id
    user = comment.user
    user.all_following.each do |follower|
      Client.where(:user_id => follower.id).each do |client|
        json = comment.active_model_serializer.new(comment).to_json(:root => false)
        begin
          PrivatePub.publish_to client.channel, "App.receiver.updateComment(#{json})"
        rescue Errno::ECONNREFUSED
          client.destroy
        end
      end
    end
  end

end